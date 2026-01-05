#!/usr/bin/env python3

from __future__ import annotations

import argparse
import os
import platform as py_platform
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable


def eprint(*args: object) -> None:
    print(*args, file=sys.stderr)


def shlex_join(parts: list[str]) -> str:
    # Avoid importing shlex on older python? It's stdlib, but keep formatting simple.
    import shlex

    return " ".join(shlex.quote(p) for p in parts)


def run(
    cmd: list[str],
    *,
    check: bool = True,
    dry_run: bool = False,
    env: dict[str, str] | None = None,
) -> subprocess.CompletedProcess[str] | None:
    if dry_run:
        print("+", shlex_join(cmd))
        return None
    return subprocess.run(cmd, check=check, text=True, env=env)


def run_bash(
    script: str,
    *,
    check: bool = True,
    dry_run: bool = False,
    env: dict[str, str] | None = None,
) -> subprocess.CompletedProcess[str] | None:
    return run(["bash", "-lc", script], check=check, dry_run=dry_run, env=env)


def load_yaml(path: Path) -> dict[str, Any]:
    try:
        import yaml  # type: ignore
    except Exception:
        eprint("Missing dependency: PyYAML.")
        eprint("Install it with: python3 -m pip install --user pyyaml")
        raise

    with path.open("r", encoding="utf-8") as f:
        data = yaml.safe_load(f)
    if not isinstance(data, dict):
        raise ValueError(f"Expected a mapping at root of {path}")
    return data


def read_os_release() -> dict[str, str]:
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
    raise RuntimeError(f"Unsupported Linux distro: ID={distro_id!r} ID_LIKE={distro_like!r}")


def platform_kind(platform_key: str) -> str:
    if platform_key in {"ubuntu", "manjaro"}:
        return "linux"
    return platform_key


def manager_for_platform(platform_key: str) -> str:
    if platform_key == "macos":
        return "brew"
    if platform_key == "ubuntu":
        return "apt"
    if platform_key == "manjaro":
        return "pacman"
    raise RuntimeError(f"Unknown platform: {platform_key}")


def uniq_keep_order(items: Iterable[str]) -> list[str]:
    seen: set[str] = set()
    out: list[str] = []
    for item in items:
        if item in seen:
            continue
        seen.add(item)
        out.append(item)
    return out


def selector_keys(platform_key: str) -> list[str]:
    keys = ["all"]
    kind = platform_kind(platform_key)
    if kind == "linux":
        keys.append("linux")
    keys.append(platform_key)
    return keys


def collect_selector_map(map_value: Any, *, platform_key: str) -> list[Any]:
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


@dataclass(frozen=True)
class Context:
    platform_key: str
    manager: str
    repo_root: Path
    dry_run: bool
    yes: bool
    do_update: bool


def ensure_home_exists() -> Path:
    home = Path.home()
    home.mkdir(parents=True, exist_ok=True)
    return home


def pkg_exists(ctx: Context, pkg_name: str) -> bool:
    if ctx.manager == "apt":
        # `apt-cache show` returns non-zero for unknown packages.
        result = subprocess.run(
            ["bash", "-lc", f"apt-cache show {shlex_join([pkg_name])} >/dev/null 2>&1"],
            check=False,
        )
        return result.returncode == 0
    if ctx.manager == "pacman":
        result = subprocess.run(["pacman", "-Si", pkg_name], check=False, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return result.returncode == 0
    if ctx.manager == "brew":
        if shutil.which("brew") is None:
            return False
        result = subprocess.run(["brew", "info", pkg_name], check=False, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return result.returncode == 0
    return False


def resolve_package_entries(ctx: Context, entries: list[Any]) -> list[str]:
    resolved: list[str] = []
    for entry in entries:
        if isinstance(entry, str):
            resolved.append(entry)
            continue
        if isinstance(entry, dict) and "any_of" in entry:
            options = entry["any_of"]
            if not isinstance(options, list) or not all(isinstance(x, str) for x in options):
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
                # Fall back to the first option to produce a useful failure message at install time.
                chosen = options[0]
            resolved.append(chosen)
            continue
        raise TypeError(f"Unsupported package entry: {entry!r}")
    return uniq_keep_order(resolved)


def install_system_packages(ctx: Context, packages: list[str], *, casks: list[str]) -> None:
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
    if not packages:
        return
    run(["python3", "-m", "pip", "install", "--user", *packages], dry_run=ctx.dry_run)


def install_pipx_packages(ctx: Context, items: list[Any]) -> None:
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


def action_vim_dirs(ctx: Context, _: dict[str, Any]) -> None:
    home = ensure_home_exists()
    run(["mkdir", "-p", str(home / ".vim" / "swap"), str(home / ".vim" / "backup")], dry_run=ctx.dry_run)


def action_vim_plug(ctx: Context, _: dict[str, Any]) -> None:
    home = ensure_home_exists()
    dest = home / ".vim" / "autoload" / "plug.vim"
    if dest.exists():
        return
    dest.parent.mkdir(parents=True, exist_ok=True)
    run(
        [
            "curl",
            "-fLo",
            str(dest),
            "--create-dirs",
            "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim",
        ],
        dry_run=ctx.dry_run,
    )


def action_tmux_config(ctx: Context, _: dict[str, Any]) -> None:
    home = ensure_home_exists()
    tmux_dir = home / ".tmux"
    tpm_dir = home / ".tmux" / "plugins" / "tpm"
    if not tmux_dir.exists():
        run(["git", "clone", "https://github.com/gpakosz/.tmux", str(tmux_dir)], dry_run=ctx.dry_run)
    # Keep compatibility with the original script's symlink location.
    run(["ln", "-sf", str(tmux_dir / ".tmux.conf"), str(home / ".tmux.conf")], dry_run=ctx.dry_run)
    if not tpm_dir.exists():
        tpm_dir.parent.mkdir(parents=True, exist_ok=True)
        run(["git", "clone", "https://github.com/tmux-plugins/tpm", str(tpm_dir)], dry_run=ctx.dry_run)


def action_docker_enable(ctx: Context, _: dict[str, Any]) -> None:
    if platform_kind(ctx.platform_key) != "linux":
        return
    import getpass

    user = os.environ.get("SUDO_USER") or os.environ.get("USER") or getpass.getuser()
    if user:
        run(["sudo", "usermod", "-a", "-G", "docker", user], check=False, dry_run=ctx.dry_run)
    if shutil.which("systemctl") is not None:
        run(["sudo", "systemctl", "enable", "--now", "docker"], check=False, dry_run=ctx.dry_run)


def action_rustup_toolchains(ctx: Context, config: dict[str, Any]) -> None:
    rustup_cfg = config.get("rustup") or {}
    if not isinstance(rustup_cfg, dict):
        rustup_cfg = {}
    install_url = rustup_cfg.get("install_url") or "https://sh.rustup.rs"
    toolchains = rustup_cfg.get("toolchains") or ["stable", "nightly"]
    if not isinstance(toolchains, list) or not all(isinstance(x, str) for x in toolchains):
        toolchains = ["stable", "nightly"]

    if shutil.which("rustup") is None:
        run_bash(f"curl -sSf {install_url} | sh -s -- -y", dry_run=ctx.dry_run)

    tc_install = " && ".join([f"rustup toolchain install {t}" for t in toolchains])
    script = f"""
        set -e
        if [ -f "$HOME/.cargo/env" ]; then
          . "$HOME/.cargo/env"
        fi
        rustup default stable || true
        {tc_install}
    """
    run_bash(script, dry_run=ctx.dry_run)


def action_nvm_node(ctx: Context, config: dict[str, Any]) -> None:
    nvm_cfg = config.get("nvm") or {}
    if not isinstance(nvm_cfg, dict):
        nvm_cfg = {}
    install_url = nvm_cfg.get("install_url") or "https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh"
    node_versions = nvm_cfg.get("node_versions") or {}
    if not isinstance(node_versions, dict):
        node_versions = {}
    node_version = node_versions.get(ctx.platform_key) or node_versions.get(platform_kind(ctx.platform_key))
    if not isinstance(node_version, (str, int, float)) or not str(node_version).strip():
        raise RuntimeError(f"Missing node version for platform {ctx.platform_key}")
    node_version = str(node_version)

    nvm_dir = Path.home() / ".nvm"
    nvm_sh = nvm_dir / "nvm.sh"
    if not nvm_sh.exists():
        run_bash(f"curl -sSfL {install_url} | bash", dry_run=ctx.dry_run)

    script = f"""
        set -e
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
        nvm install {node_version}
        nvm alias default {node_version}
    """
    run_bash(script, dry_run=ctx.dry_run)


ACTIONS: dict[str, Any] = {
    "vim_dirs": action_vim_dirs,
    "vim_plug": action_vim_plug,
    "tmux_config": action_tmux_config,
    "docker_enable": action_docker_enable,
    "rustup_toolchains": action_rustup_toolchains,
    "nvm_node": action_nvm_node,
}


def resolve_profile_modules(data: dict[str, Any], names: list[str]) -> list[str]:
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


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description="Install dependencies from setup/dependencies.yaml")
    parser.add_argument("--platform", choices=["macos", "ubuntu", "manjaro"], help="Override platform detection")
    parser.add_argument("--profile", default="default", help="Profile name from dependencies.yaml")
    parser.add_argument("--module", action="append", default=[], help="Extra module(s) to include")
    parser.add_argument("--dry-run", action="store_true", help="Print commands without running them")
    parser.add_argument("--yes", action="store_true", help="Auto-confirm package manager prompts where supported")
    parser.add_argument("--no-update", action="store_true", help="Skip package DB updates (brew/apt)")
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
                raise TypeError(f"module {module_name}: packages[{ctx.manager}] must be a list")
            pkg_entries.extend(manager_entries)

        cask_map = module.get("casks") or {}
        if cask_map:
            if not isinstance(cask_map, dict):
                raise TypeError(f"module {module_name}: casks must be a mapping")
            if ctx.manager == "brew":
                brew_casks = cask_map.get("brew") or []
                if not isinstance(brew_casks, list) or not all(isinstance(x, str) for x in brew_casks):
                    raise TypeError(f"module {module_name}: casks.brew must be a list of strings")
                casks.extend(brew_casks)

        pip_map = module.get("pip")
        pip_items = collect_selector_map(pip_map, platform_key=ctx.platform_key)
        if pip_items:
            if not all(isinstance(x, str) for x in pip_items):
                raise TypeError(f"module {module_name}: pip entries must be strings")
            pip_pkgs.extend(pip_items)

        pipx_map = module.get("pipx")
        pipx_items.extend(collect_selector_map(pipx_map, platform_key=ctx.platform_key))

        action_map = module.get("actions")
        action_items = collect_selector_map(action_map, platform_key=ctx.platform_key)
        for a in action_items:
            if not isinstance(a, str):
                raise TypeError(f"module {module_name}: action entries must be strings")
            actions.append(a)

    packages = resolve_package_entries(ctx, pkg_entries)
    casks = uniq_keep_order(casks)
    pip_pkgs = uniq_keep_order(pip_pkgs)
    actions = uniq_keep_order(actions)

    install_system_packages(ctx, packages, casks=casks)
    install_pip_packages(ctx, pip_pkgs)
    install_pipx_packages(ctx, pipx_items)

    for action in actions:
        fn = ACTIONS.get(action)
        if fn is None:
            raise RuntimeError(f"Unknown action: {action}")
        fn(ctx, config)

    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main(sys.argv[1:]))
    except subprocess.CalledProcessError as e:
        eprint(f"Command failed with exit code {e.returncode}: {e.cmd}")
        raise
