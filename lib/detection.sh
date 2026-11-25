#!/usr/bin/env bash
detect_os() { python3 "$BASE/lib/manager.py" --info "$@"; }
detect_navicat() { python3 "$BASE/lib/manager.py" --detect "$@"; }
detect_navicat_version() { python3 "$BASE/lib/manager.py" --detect "$@"; }
detect_installation_type() { python3 "$BASE/lib/manager.py" --detect "$@"; }
discover_config_paths() { python3 "$BASE/lib/manager.py" --analyze "$@"; }
check_running_processes() { python3 "$BASE/lib/manager.py" --detect "$@"; }
