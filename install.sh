#!/usr/bin/env bash
set -Eeuo pipefail
umask 077
BASE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
prefix=${HOME}/.local
if [[ ${1:-} == --system ]]; then prefix=/usr/local; elif (($#)); then printf 'Usage: %s [--system]\n' "$0" >&2; exit 1; fi
if [[ $prefix == /usr/local ]]; then umask 022; fi
command -v python3 >/dev/null
[[ ! -L "$prefix/bin" && ! -L "$prefix/lib" ]] || exit 1
mkdir -p -- "$prefix/bin" "$prefix/lib"
dest=$prefix/lib/navicat-linux-manager
[[ ! -e "$dest" && ! -L "$dest" && ! -e "$prefix/bin/navicat-manager" && ! -L "$prefix/bin/navicat-manager" ]] || { printf 'Installation exists; uninstall it first.\n' >&2; exit 1; }
mkdir -- "$dest"
cp -R -- "$BASE/lib" "$BASE/navicat-manager.sh" "$BASE/uninstall.sh" "$dest/"
printf '%s\n' 'navicat-linux-manager 1' > "$dest/.installed"
chmod 755 "$dest/navicat-manager.sh" "$dest/uninstall.sh"
ln -s -- "$dest/navicat-manager.sh" "$prefix/bin/navicat-manager"
printf 'Installed. Ensure %s/bin is in PATH.\n' "$prefix"
