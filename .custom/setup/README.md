# Setup

Dependencies are defined in `setup/dependencies.yaml` and installed
via `setup/install.py`.

## Usage

- macOS: `./macos/install.sh`
- Ubuntu: `./ubuntu/install.sh`
- Manjaro: `./manjaro/install.sh`

Common options:

- Dry run (no exec bit required): `bash ./setup/install.sh --dry-run`
- Select profile: `bash ./setup/install.sh --profile default`
- Add modules: `bash ./setup/install.sh --module desktop-manjaro`
- Auto-confirm where supported: `bash ./setup/install.sh --yes`
- Skip package DB updates (brew/apt): `bash ./setup/install.sh --no-update`

Notes:

- `bash ./setup/install.sh` bootstraps PyYAML (via `pip --user`) if needed.
- Some steps require `sudo` (apt/pacman installs, docker enablement).

## Profiles

Profiles are defined under `profiles` in `setup/dependencies.yaml`.

- `default`: shared dev environment setup across OSes
- `manjaro-desktop`: `default` + Manjaro desktop apps/utilities

## Editing dependencies

- Add/adjust system packages in `modules.<name>.packages` keyed by
  package manager (`brew`, `apt`, `pacman`).
- Add macOS apps in `modules.<name>.casks.brew`.
- Add Python user packages in `modules.<name>.pip`
  (selectors: `all`, `linux`, `macos`, `ubuntu`, `manjaro`).
- Add global npm packages in `modules.<name>.npm`
  (selectors: `all`, `linux`, `macos`, `ubuntu`, `manjaro`).
- Add scripted steps in `modules.<name>.actions`
  (implemented in `setup/install_actions.py`).
