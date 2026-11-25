from pathlib import Path
p = Path(__file__).resolve().parents[1]
out = p / 'standalone/navicat-manager.sh'
out.parent.mkdir(exist_ok=True)
out.write_text('#!/usr/bin/env bash\nset -Eeuo pipefail\numask 077\nexec python3 - "$@" <<\'NAVICAT_MANAGER_PY\'\n' + (p / 'lib/manager.py').read_text() + '\nNAVICAT_MANAGER_PY\n', newline='\n')
