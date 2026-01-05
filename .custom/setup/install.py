#!/usr/bin/env python3

"""
Data-driven setup installer.

This script reads `setup/dependencies.yaml` and installs the requested modules
via the host OS package manager (brew/apt/pacman), plus optional `pip`/`pipx`
packages and a small set of scripted actions (e.g. nvm/rustup bootstrap).

Supported platforms:
  - macOS  -> Homebrew (`brew`)
  - Ubuntu -> APT (`apt-get`)
  - Manjaro/Arch -> pacman
"""

from __future__ import annotations

import argparse
import platform as py_platform
import shlex
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Any, Iterable

from install_actions import ACTIONS
from install_core import Context, platform_kind, run, shlex_join


# ------------------------------ Output Helpers ------------------------------


def error_print(*args: object) -> None:
    print(*args, file=sys.stderr)


# ------------------------------ YAML Dependency ------------------------------

try:
    import yaml  # type: ignore
except Exception:
    error_print("Missing dependency: PyYAML.")
    error_print("Install it with: python3 -m pip install --user pyyaml")
    raise


# ---------------------------- Command Execution -----------------------------


def load_yaml(path: Path) -> dict[str, Any]:
    """Load a YAML file and return its contents as a dictionary.

    Args:
        path: Path to the YAML file.

    Returns:
        A dictionary representing the YAML file contents.
    """
    with path.open("r", encoding="utf-8") as f:
        data = yaml.safe_load(f)
    if not isinstance(data, dict):
        raise ValueError(f"Expected a mapping at root of {path}")
    return data


# ---------------------------- Platform Detection ----------------------------


def read_os_release() -> dict[str, str]:
    """Read /etc/os-release and return its contents as a dictionary.

    Returns:
        A dictionary of key-value pairs from /etc/os-release.
    """
    os_release = Path("/etc/os-release")
    if not os_release.exists():
        return {}
    data: dict[str, str] = {}
    for line in os_release.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        k, v = line.split("=", 1)
        data[k] = v.strip().strip('"')
    return data


def detect_platform() -> str:
    """Detect the current platform and return a platform key.

    Returns:
        A string platform key, one of "macos", "ubuntu", or "manjaro".
    """
    sysname = py_platform.system().lower()

    if sysname == "darwin":
        return "macos"
    if sysname != "linux":
        raise RuntimeError(f"Unsupported OS: {py_platform.system()}")

    osr = read_os_release()
    distro_id = (osr.get("ID") or "").lower()
    distro_like = (osr.get("ID_LIKE") or "").lower()

    if distro_id == "ubuntu" or "ubuntu" in distro_like or "debian" in distro_like:
        return "ubuntu"
    if distro_id in {"manjaro", "arch"} or "arch" in distro_like:
        return "manjaro"

    raise RuntimeError(
        f"Unsupported Linux distro: ID={distro_id!r} ID_LIKE={distro_like!r}"
    )


def manager_for_platform(platform_key: str) -> str:
    """Return the package manager for a given platform key.

    Args:
        platform_key: The specific platform key (e.g. "macos", "ubuntu", "manjaro")

    Returns:
        The package manager key ("brew", "apt", "pacman").
    """
    if platform_key == "macos":
        return "brew"
    if platform_key == "ubuntu":
        return "apt"
    if platform_key == "manjaro":
        return "pacman"

    raise RuntimeError(f"Unknown platform: {platform_key}")


# -------------------------- Selectors / List Helpers -------------------------


def uniq_keep_order(items: Iterable[str]) -> list[str]:
    """Return a list of unique items, preserving their original order.

    Args:
        items: An iterable of strings.

    Returns:
        A list of unique strings in their original order.
    """
    seen: set[str] = set()
    out: list[str] = []
    for item in items:
        if item in seen:
            continue
        seen.add(item)
        out.append(item)
    return out


def selector_keys(platform_key: str) -> list[str]:
    """Return the selector keys for a given platform key.

    Args:
        platform_key: The specific platform key (e.g., "ubuntu", "manjaro")

    Returns:
        A list of selector keys in order of precedence.

    """
    keys = ["all"]
    kind = platform_kind(platform_key)
    if kind == "linux":
        keys.append("linux")
    keys.append(platform_key)
    return keys


def collect_selector_map(map_value: Any, *, platform_key: str) -> list[Any]:
    """Collect items from a selector map based on platform key.

    Args:
        map_value: The selector map (dict) or list of items.
        platform_key: The specific platform key (e.g., "ubuntu", "manjaro")

    Returns:
        A list of collected items.
    """
    if map_value is None:
        return []

    if isinstance(map_value, list):
        return map_value

    if not isinstance(map_value, dict):
        raise TypeError(f"Expected list or mapping, got {type(map_value)}")

    out: list[Any] = []
    for k in selector_keys(platform_key):
        v = map_value.get(k)
        if v is None:
            continue
        if not isinstance(v, list):
            raise TypeError(f"Expected list for selector {k!r}, got {type(v)}")
        out.extend(v)
    return out


# ------------------------------ Install Context ------------------------------


def pkg_exists(ctx: Context, pkg_name: str) -> bool:
    """Check if a package exists in the package manager's repository.

    Args:
        ctx: The installation context.
        pkg_name: The name of the package to check.

    Returns:
        True if the package exists, False otherwise.
    """
    if ctx.manager == "apt":
        # `apt-cache show` returns non-zero for unknown packages.
        result = subprocess.run(
            ["bash", "-lc", f"apt-cache show {shlex_join([pkg_name])} >/dev/null 2>&1"],
            check=False,
        )
        return result.returncode == 0

    if ctx.manager == "pacman":
        result = subprocess.run(
            ["pacman", "-Si", pkg_name],
            check=False,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        return result.returncode == 0

    if ctx.manager == "brew":
        if shutil.which("brew") is None:
            return False
        result = subprocess.run(
            ["brew", "info", pkg_name],
            check=False,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        return result.returncode == 0
    return False


def resolve_package_entries(ctx: Context, entries: list[Any]) -> list[str]:
    """Resolve package entries into concrete package names.

    Supported entry forms:
      - "pkg-name"
      - {"any_of": ["candidate-a", "candidate-b", ...]}

    The `any_of` form is useful for distro-specific renames (e.g. `clangd` vs
    `clangd-10`); the first known package is chosen.
    """
    resolved: list[str] = []
    for entry in entries:
        if isinstance(entry, str):
            resolved.append(entry)
            continue
        if isinstance(entry, dict) and "any_of" in entry:
            options = entry["any_of"]
            if not isinstance(options, list) or not all(
                isinstance(x, str) for x in options
            ):
                raise TypeError("'any_of' must be a list of strings")

            chosen = None
            for opt in options:
                if ctx.dry_run:
                    chosen = opt
                    break
                if pkg_exists(ctx, opt):
                    chosen = opt
                    break

            if chosen is None:
                # Fall back to the first option to produce a useful failure
                # message at install time.
                chosen = options[0]
            resolved.append(chosen)
            continue

        raise TypeError(f"Unsupported package entry: {entry!r}")
    return uniq_keep_order(resolved)


# ---------------------------- System/Python Installs -------------------------


def install_system_packages(
    ctx: Context, packages: list[str], *, casks: list[str]
) -> None:
    """Install system packages via the platform package manager.

    - `brew`: installs formulae and optional `--cask` apps.
    - `apt`: optionally runs `apt-get update`, then installs packages.
    - `pacman`: uses `-Syu --needed` to update/upgrade and install.
    """
    if not packages and not casks:
        return

    if ctx.manager == "apt":
        if ctx.do_update:
            run(["sudo", "apt-get", "update"], dry_run=ctx.dry_run)
        cmd = ["sudo", "apt-get", "install"]
        if ctx.yes:
            cmd.append("-y")
        cmd.extend(packages)
        run(cmd, dry_run=ctx.dry_run)
        return

    if ctx.manager == "pacman":
        # `-Syu` to ensure package DB is current and upgrades are applied.
        cmd = ["sudo", "pacman", "-Syu", "--needed"]
        if ctx.yes:
            cmd.append("--noconfirm")
        cmd.extend(packages)
        run(cmd, dry_run=ctx.dry_run)
        return

    if ctx.manager == "brew":
        if shutil.which("brew") is None:
            raise RuntimeError("Homebrew is required but `brew` was not found in PATH.")
        if ctx.do_update:
            run(["brew", "update"], dry_run=ctx.dry_run)
        if packages:
            run(["brew", "install", *packages], dry_run=ctx.dry_run)
        if casks:
            run(["brew", "install", "--cask", *casks], dry_run=ctx.dry_run)
        return

    raise RuntimeError(f"Unsupported package manager: {ctx.manager}")


def install_pip_packages(ctx: Context, packages: list[str]) -> None:
    """Install Python packages into the user site-packages via `pip`."""
    if not packages:
        return
    run(["python3", "-m", "pip", "install", "--user", *packages], dry_run=ctx.dry_run)


def install_pipx_packages(ctx: Context, items: list[Any]) -> None:
    """Install applications via `pipx`.

    Supported entry forms:
      - "package-name"
      - {"name": "package-name", "python": "python3.12"}
    """
    if not items:
        return
    pipx_cmd = shutil.which("pipx")
    if pipx_cmd is None and not ctx.dry_run:
        raise RuntimeError("pipx not found; install it via your system packages first.")
    for item in items:
        if isinstance(item, str):
            cmd = ["pipx", "install", item]
            run(cmd, dry_run=ctx.dry_run)
            continue
        if isinstance(item, dict):
            name = item.get("name")
            if not isinstance(name, str) or not name:
                raise TypeError(f"Invalid pipx item: {item!r}")
            cmd = ["pipx", "install", name]
            python = item.get("python")
            if isinstance(python, str) and python:
                cmd.extend(["--python", python])
            run(cmd, dry_run=ctx.dry_run)
            continue
        raise TypeError(f"Unsupported pipx entry: {item!r}")


def install_npm_packages(ctx: Context, packages: list[str]) -> None:
    """Install global npm packages.

    On systems using nvm, `npm` may not be on PATH for non-interactive processes.
    We therefore run through a login shell and source `nvm.sh` when present.
    """
    if not packages:
        return

    pkgs = " ".join(shlex.quote(p) for p in packages)
    script = f"""
        set -e
        if ! command -v npm >/dev/null 2>&1; then
          export NVM_DIR="$HOME/.nvm"
          [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
        fi
        if ! command -v npm >/dev/null 2>&1; then
          echo "npm not found. Install Node.js first (e.g. include the languages-node module)." >&2
          exit 1
        fi
        npm i -g {pkgs}
    """
    run_bash(script, dry_run=ctx.dry_run)


# --------------------------- Profile/Module Resolve --------------------------


def resolve_profile_modules(data: dict[str, Any], names: list[str]) -> list[str]:
    """Resolve a list of module/profile names into module names.

    Profiles can include other profiles (nested) and/or modules.
    """
    profiles = data.get("profiles") or {}
    modules = data.get("modules") or {}
    if not isinstance(profiles, dict) or not isinstance(modules, dict):
        raise ValueError("Invalid dependencies.yaml (profiles/modules)")

    resolved: list[str] = []

    def add_name(name: str) -> None:
        if name in profiles:
            profile = profiles[name]
            if not isinstance(profile, dict) or "modules" not in profile:
                raise ValueError(f"Invalid profile {name!r}")
            sub = profile["modules"]
            if not isinstance(sub, list) or not all(isinstance(x, str) for x in sub):
                raise ValueError(f"Invalid modules list in profile {name!r}")
            for s in sub:
                add_name(s)
            return
        if name not in modules:
            raise ValueError(f"Unknown module/profile: {name}")
        resolved.append(name)

    for name in names:
        add_name(name)

    return uniq_keep_order(resolved)


# ----------------------------------- CLI -----------------------------------


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(
        description="Install dependencies from setup/dependencies.yaml",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "Examples:\n"
            "  # Install the default profile for this machine\n"
            "  python3 setup/install.py --profile default\n"
            "\n"
            "  # Show what would be executed\n"
            "  python3 setup/install.py --dry-run\n"
            "\n"
            "  # Add a module in addition to the profile\n"
            "  python3 setup/install.py --profile default --module clangd\n"
        ),
    )
    parser.add_argument(
        "--platform",
        choices=["macos", "ubuntu", "manjaro"],
        help="Override platform detection (otherwise auto-detected)",
    )
    parser.add_argument(
        "--profile",
        default="default",
        help="Profile name from dependencies.yaml (profiles expand to modules)",
    )
    parser.add_argument(
        "--module",
        action="append",
        default=[],
        help="Extra module(s) to include (repeatable)",
    )
    parser.add_argument(
        "--dry-run", action="store_true", help="Print commands without running them"
    )
    parser.add_argument(
        "--yes",
        action="store_true",
        help="Auto-confirm package manager prompts where supported (apt/pacman)",
    )
    parser.add_argument(
        "--no-update",
        action="store_true",
        help="Skip package DB updates (brew/apt only)",
    )
    args = parser.parse_args(argv)

    platform_key = args.platform or detect_platform()
    manager = manager_for_platform(platform_key)

    repo_root = Path(__file__).resolve().parents[1]
    deps_path = repo_root / "setup" / "dependencies.yaml"
    data = load_yaml(deps_path)

    module_names = resolve_profile_modules(data, [args.profile, *args.module])
    config = data.get("config") or {}
    if not isinstance(config, dict):
        config = {}

    ctx = Context(
        platform_key=platform_key,
        manager=manager,
        repo_root=repo_root,
        dry_run=bool(args.dry_run),
        yes=bool(args.yes),
        do_update=not args.no_update,
    )

    modules = data.get("modules") or {}
    if not isinstance(modules, dict):
        raise ValueError("Invalid modules in dependencies.yaml")

    pkg_entries: list[Any] = []
    casks: list[str] = []
    pip_pkgs: list[str] = []
    pipx_items: list[Any] = []
    npm_pkgs: list[str] = []
    actions: list[str] = []

    for module_name in module_names:
        module = modules[module_name]
        if not isinstance(module, dict):
            raise ValueError(f"Invalid module: {module_name}")

        packages = module.get("packages") or {}
        if packages is not None:
            if not isinstance(packages, dict):
                raise TypeError(f"module {module_name}: packages must be a mapping")
            manager_entries = packages.get(ctx.manager) or []
            if not isinstance(manager_entries, list):
                raise TypeError(
                    f"module {module_name}: packages[{ctx.manager}] must be a list"
                )
            pkg_entries.extend(manager_entries)

        cask_map = module.get("casks") or {}
        if cask_map:
            if not isinstance(cask_map, dict):
                raise TypeError(f"module {module_name}: casks must be a mapping")
            if ctx.manager == "brew":
                brew_casks = cask_map.get("brew") or []
                if not isinstance(brew_casks, list) or not all(
                    isinstance(x, str) for x in brew_casks
                ):
                    raise TypeError(
                        f"module {module_name}: casks.brew must be a list of strings"
                    )
                casks.extend(brew_casks)

        pip_map = module.get("pip")
        pip_items = collect_selector_map(pip_map, platform_key=ctx.platform_key)
        if pip_items:
            if not all(isinstance(x, str) for x in pip_items):
                raise TypeError(f"module {module_name}: pip entries must be strings")
            pip_pkgs.extend(pip_items)

        pipx_map = module.get("pipx")
        pipx_items.extend(collect_selector_map(pipx_map, platform_key=ctx.platform_key))

        npm_map = module.get("npm")
        npm_items = collect_selector_map(npm_map, platform_key=ctx.platform_key)
        if npm_items:
            if not all(isinstance(x, str) for x in npm_items):
                raise TypeError(f"module {module_name}: npm entries must be strings")
            npm_pkgs.extend(npm_items)

        action_map = module.get("actions")
        action_items = collect_selector_map(action_map, platform_key=ctx.platform_key)
        for a in action_items:
            if not isinstance(a, str):
                raise TypeError(f"module {module_name}: action entries must be strings")
            actions.append(a)

    packages = resolve_package_entries(ctx, pkg_entries)
    casks = uniq_keep_order(casks)
    pip_pkgs = uniq_keep_order(pip_pkgs)
    npm_pkgs = uniq_keep_order(npm_pkgs)
    actions = uniq_keep_order(actions)

    install_system_packages(ctx, packages, casks=casks)
    install_pip_packages(ctx, pip_pkgs)
    install_pipx_packages(ctx, pipx_items)

    for action in actions:
        fn = ACTIONS.get(action)
        if fn is None:
            raise RuntimeError(f"Unknown action: {action}")
        fn(ctx, config)

    install_npm_packages(ctx, npm_pkgs)

    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main(sys.argv[1:]))
    except subprocess.CalledProcessError as e:
        error_print(f"Command failed with exit code {e.returncode}: {e.cmd}")
        raise
