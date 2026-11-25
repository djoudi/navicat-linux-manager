# Navicat Premium Linux Manager

Version 1.0.0. Independent maintenance utility, not a PremiumSoft product.
Strict Bash entry points use a Python 3 standard-library filesystem engine.
No registration, activation or trial files are targeted.

## Install

```bash
chmod +x install.sh
./install.sh
export PATH="$HOME/.local/bin:$PATH"
navicat-manager --help
```

Requires Linux, Bash 4+, Python 3.8+, and a normal desktop user. Do not run the
manager as root. Optional system installation: `sudo bash install.sh --system`.

## Use

```bash
navicat-manager                         # interactive menu
navicat-manager --detect
navicat-manager --info
navicat-manager --diagnose
navicat-manager --backup --dry-run
navicat-manager --backup
navicat-manager --backup-connections
navicat-manager --restore "$HOME/.local/state/navicat-manager/BACKUP-ID" --dry-run
navicat-manager --restore "$HOME/.local/state/navicat-manager/BACKUP-ID" --yes
navicat-manager --repair "$HOME/.local/state/navicat-manager/BACKUP-ID" --yes
navicat-manager --permissions
navicat-manager --rollback --yes
navicat-manager --launch --executable "$HOME/Applications/navicat.AppImage"
```

Close Navicat before backups or changes. Confirm paths in Navicat first.
Only `Common/connections.json` and `Premium/Profiles` beneath the selected config
root are included by default. Both backup commands include these data sets;
neither exports NCX or database contents. Repeat `--profile-path PATH` for custom
Settings Locations. Use the same options when restoring.

The default root is `$XDG_CONFIG_HOME/navicat`, falling back to
`~/.config/navicat`. This XDG convention is a discovery assumption; verify it in
Navicat. Select another root with `--config-root PATH`.

Cache and temporary paths are never guessed:

```bash
navicat-manager --clean-cache --cache-path "$HOME/verified-navicat-cache" --dry-run
navicat-manager --clean-cache --cache-path "$HOME/verified-navicat-cache" --yes
navicat-manager --rollback --cache-path "$HOME/verified-navicat-cache" --yes
navicat-manager --clean-temporary --temporary-path "$HOME/verified-navicat-temp" --yes
```

Only supply independently verified disposable Navicat directories. All managed
paths must be within your home, owned by you, without symlinks or hard links.
Configuration and state overlaps are rejected for cleanup.

Backups are private directories under `$XDG_STATE_HOME/navicat-manager`, default
`~/.local/state/navicat-manager`. They are not encrypted. Never share them.
Diagnostics print local paths but never file contents, environment variables or
process command lines. `--verbose` is accepted but keeps the same bounded output.

## Distributions and compatibility

The modular distribution requires `navicat-manager.sh` and its adjacent `lib/`.
`standalone/navicat-manager.sh` is a single-file Bash distribution that also
requires Python 3. Regenerate with `python3 tools/build-standalone.py`.

| Environment | Status |
|---|---|
| Ubuntu 26.04 x86_64 WSL | Synthetic-data tests executed; see docs/VALIDATION.md |
| Ubuntu 24.04 desktop | Targeted, not executed locally |
| Navicat 17 / 18 | Vendor paths investigated; application integration untested |
| AppImage / native launcher | Explicit executable supported; actual launch untested |
| Flatpak / portable config overrides | Requires confirmed paths; automatic launch unsupported |
| Future Ubuntu / Navicat | Conditional on compatible runtime and confirmed paths; untested |

See [architecture](docs/ARCHITECTURE.md), [guide](docs/USER_GUIDE.md),
[installation](docs/INSTALLATION.md), [troubleshooting](docs/TROUBLESHOOTING.md)
and [security](SECURITY.md).
