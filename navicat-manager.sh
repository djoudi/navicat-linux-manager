#!/usr/bin/env bash
set -Eeuo pipefail
umask 077
BASE=$(cd -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")" && pwd)
for module in common detection backup maintenance logging; do
    # shellcheck source=/dev/null
    source "$BASE/lib/$module.sh"
done
main() {
    check_dependencies
    if (($#)); then python3 "$BASE/lib/manager.py" "$@"; else show_menu; fi
}
main "$@"
