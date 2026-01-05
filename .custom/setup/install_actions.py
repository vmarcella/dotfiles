#!/usr/bin/env python3

"""
Scripted actions for `setup/install.py`.

These actions are referenced by name from `setup/dependencies.yaml` and executed
after system/pip/pipx installs. Keeping them in their own module makes the main
installer easier to read and reduces merge conflicts as this list grows.

All actions should be safe to run multiple times (idempotent) where feasible.
"""

from __future__ import annotations

import getpass
import os
import shutil
from pathlib import Path
from typing import Any

from install_core import Context, ensure_home_exists, platform_kind, run, run_bash


def action_vim_dirs(ctx: Context, _: dict[str, Any]) -> None:
    """Create Vim/Neovim swap/backup directories."""
    home = ensure_home_exists()
    run(
        ["mkdir", "-p", str(home / ".vim" / "swap"), str(home / ".vim" / "backup")],
        dry_run=ctx.dry_run,
    )


def action_vim_plug(ctx: Context, _: dict[str, Any]) -> None:
    """Install vim-plug if not already present."""
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
    """Install gpakosz/.tmux and TPM, then link `~/.tmux.conf`."""
    home = ensure_home_exists()
    tmux_dir = home / ".tmux"
    tpm_dir = home / ".tmux" / "plugins" / "tpm"
    if not tmux_dir.exists():
        run(
            ["git", "clone", "https://github.com/gpakosz/.tmux", str(tmux_dir)],
            dry_run=ctx.dry_run,
        )
    run(
        ["ln", "-sf", str(tmux_dir / ".tmux.conf"), str(home / ".tmux.conf")],
        dry_run=ctx.dry_run,
    )
    if not tpm_dir.exists():
        tpm_dir.parent.mkdir(parents=True, exist_ok=True)
        run(
            ["git", "clone", "https://github.com/tmux-plugins/tpm", str(tpm_dir)],
            dry_run=ctx.dry_run,
        )


def action_docker_enable(ctx: Context, _: dict[str, Any]) -> None:
    """Enable Docker on Linux (group membership + systemd enable/start)."""
    if platform_kind(ctx.platform_key) != "linux":
        return

    user = os.environ.get("SUDO_USER") or os.environ.get("USER") or getpass.getuser()

    if user:
        run(
            ["sudo", "usermod", "-a", "-G", "docker", user],
            check=False,
            dry_run=ctx.dry_run,
        )
    if shutil.which("systemctl") is not None:
        run(
            ["sudo", "systemctl", "enable", "--now", "docker"],
            check=False,
            dry_run=ctx.dry_run,
        )


def action_rustup_toolchains(ctx: Context, config: dict[str, Any]) -> None:
    """Ensure rustup exists and install configured toolchains."""
    rustup_cfg = config.get("rustup") or {}

    if not isinstance(rustup_cfg, dict):
        rustup_cfg = {}

    install_url = rustup_cfg.get("install_url") or "https://sh.rustup.rs"
    toolchains = rustup_cfg.get("toolchains") or ["stable", "nightly"]

    if not isinstance(toolchains, list) or not all(
        isinstance(x, str) for x in toolchains
    ):
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
    """Ensure nvm exists and install the configured Node version."""
    nvm_cfg = config.get("nvm") or {}
    if not isinstance(nvm_cfg, dict):
        nvm_cfg = {}
    install_url = (
        nvm_cfg.get("install_url")
        or "https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh"
    )
    node_versions = nvm_cfg.get("node_versions") or {}
    if not isinstance(node_versions, dict):
        node_versions = {}
    node_version = node_versions.get(ctx.platform_key) or node_versions.get(
        platform_kind(ctx.platform_key)
    )
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
