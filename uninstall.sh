#!/usr/bin/env bash
set -Eeuo pipefail
prefix=${HOME}/.local
if [[ ${1:-} == --system ]]; then prefix=/usr/local; elif (($#)); then printf 'Usage: %s [--system]\n' "$0" >&2; exit 1; fi
dest=$prefix/lib/navicat-linux-manager
[[ ! -L "$dest" && -f "$dest/.installed" && $(cat -- "$dest/.installed") == 'navicat-linux-manager 1' ]] || { printf 'Verified installation not found.\n' >&2; exit 1; }
[[ $(readlink -- "$prefix/bin/navicat-manager") == "$dest/navicat-manager.sh" ]] || exit 1
rm -- "$prefix/bin/navicat-manager"
rm -r -- "$dest"
printf 'Removed utility. Application data and manager backups retained.\n'
