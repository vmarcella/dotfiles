#!/usr/bin/env bash
set -euo pipefail

# Bootstrap wrapper for `setup/install.py`.
#
# Responsibilities:
# - Detect platform (or honor `--platform <macos|ubuntu|manjaro>`).
# - Ensure `python3` and `pip` exist (via brew/apt/pacman as needed).
# - Ensure PyYAML exists (via `python3 -m pip install --user pyyaml`).
# - Delegate to `setup/install.py` with the original arguments.
#
# Tip: use `--dry-run` to print the commands without executing them.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"

# ------------------------------ Platform Detect ------------------------------

detect_platform() {
  local sys
  sys="$(uname -s)"
  if [[ "$sys" == "Darwin" ]]; then
    echo "macos"
    return 0
  fi
  if [[ "$sys" != "Linux" ]]; then
    echo "unsupported"
    return 1
  fi

  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    case "${ID:-}" in
      ubuntu) echo "ubuntu"; return 0 ;;
      manjaro|arch) echo "manjaro"; return 0 ;;
    esac
    case "${ID_LIKE:-}" in
      *debian*|*ubuntu*) echo "ubuntu"; return 0 ;;
      *arch*) echo "manjaro"; return 0 ;;
    esac
  fi

  echo "unsupported"
  return 1
}

# -------------------------------- Homebrew ---------------------------------

ensure_brew() {
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Best-effort: make `brew` available to the current shell.
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

# ----------------------------- Python Bootstraps -----------------------------

bootstrap_python() {
  local platform="$1"
  if command -v python3 >/dev/null 2>&1; then
    return 0
  fi

  case "$platform" in
    macos)
      ensure_brew
      brew install python
      ;;
    ubuntu)
      sudo apt-get update
      sudo apt-get install -y python3 python3-pip
      ;;
    manjaro)
      sudo pacman -Syu --needed python python-pip
      ;;
    *)
      echo "Unsupported platform for bootstrap: $platform" >&2
      return 1
      ;;
  esac
}

bootstrap_pip() {
  local platform="$1"
  if python3 -m pip --version >/dev/null 2>&1; then
    return 0
  fi
  case "$platform" in
    macos)
      ensure_brew
      brew install python
      ;;
    ubuntu)
      sudo apt-get update
      sudo apt-get install -y python3-pip
      ;;
    manjaro)
      sudo pacman -Syu --needed python-pip
      ;;
    *)
      echo "Unsupported platform for bootstrap: $platform" >&2
      return 1
      ;;
  esac
}

bootstrap_pyyaml() {
  if python3 -c "import yaml" >/dev/null 2>&1; then
    return 0
  fi
  python3 -m pip install --user --break-system-packages pyyaml
}

# --------------------------------- Runner ----------------------------------

platform=""
for ((i = 1; i <= $#; i++)); do
  arg="${!i}"
  if [[ "$arg" == "--platform" ]]; then
    j=$((i + 1))
    platform="${!j:-}"
    break
  fi
done
platform="${platform:-$(detect_platform)}"

bootstrap_python "$platform"
bootstrap_pip "$platform"
bootstrap_pyyaml

exec python3 "$REPO_ROOT/setup/install.py" "$@"
