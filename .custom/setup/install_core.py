#!/usr/bin/env python3

"""
Shared primitives for the data-driven installer.

This module is intentionally small and dependency-free so that:
  - `setup/install.py` can stay focused on parsing YAML + orchestration
  - action implementations can live in their own module without circular imports

All paths are resolved from `__file__` in the caller and/or from `Context.repo_root`,
so execution is stable regardless of the current working directory.
"""

from __future__ import annotations

import shlex
import subprocess
from dataclasses import dataclass
from pathlib import Path


def shlex_join(parts: list[str]) -> str:
    """Shell-escape and join argv parts into a printable command string."""
    return " ".join(shlex.quote(p) for p in parts)


def run(
    cmd: list[str],
    *,
    check: bool = True,
    dry_run: bool = False,
    env: dict[str, str] | None = None,
) -> subprocess.CompletedProcess[str] | None:
    """Run a command (argv style), optionally as a dry-run."""
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
    """Run a bash snippet via `bash -lc`."""
    return run(["bash", "-lc", script], check=check, dry_run=dry_run, env=env)


@dataclass(frozen=True)
class Context:
    """Context for installation operations."""

    platform_key: str
    manager: str
    repo_root: Path
    dry_run: bool
    yes: bool
    do_update: bool


def platform_kind(platform_key: str) -> str:
    """Map specific platforms to broader kinds (e.g. ubuntu/manjaro -> linux)."""
    if platform_key in {"ubuntu", "manjaro"}:
        return "linux"
    return platform_key


def ensure_home_exists() -> Path:
    """Ensure the user's home directory exists and return it."""
    home = Path.home()
    home.mkdir(parents=True, exist_ok=True)
    return home
