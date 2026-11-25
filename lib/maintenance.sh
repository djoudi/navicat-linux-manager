#!/usr/bin/env bash
clean_cache() { python3 "$BASE/lib/manager.py" --clean-cache "$@"; }
clean_temporary_files() { python3 "$BASE/lib/manager.py" --clean-temporary "$@"; }
repair_configuration() { python3 "$BASE/lib/manager.py" --repair "$@"; }
verify_permissions() { python3 "$BASE/lib/manager.py" --permissions "$@"; }
generate_diagnostic_report() { python3 "$BASE/lib/manager.py" --diagnose "$@"; }
launch_navicat() { python3 "$BASE/lib/manager.py" --launch "$@"; }
