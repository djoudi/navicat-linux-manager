#!/usr/bin/env bash
check_dependencies() { command -v python3 >/dev/null || { printf 'Python 3 is required.\n' >&2; return 1; }; }
show_help() { python3 "$BASE/lib/manager.py" --help; }
show_menu() { python3 "$BASE/lib/manager.py"; }
