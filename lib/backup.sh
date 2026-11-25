#!/usr/bin/env bash
backup_configuration() { python3 "$BASE/lib/manager.py" --backup "$@"; }
backup_connections() { python3 "$BASE/lib/manager.py" --backup-connections "$@"; }
restore_configuration() { python3 "$BASE/lib/manager.py" --restore "$@"; }
rollback_changes() { python3 "$BASE/lib/manager.py" --rollback "$@"; }
