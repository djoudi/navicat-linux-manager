#!/usr/bin/env bash
set -Eeuo pipefail
umask 077
exec python3 - "$@" <<'NAVICAT_MANAGER_PY'
"""Conservative data-only maintenance engine. No registration/trial paths are managed."""
import argparse
import contextlib
import datetime
import hashlib
import json
import os
from pathlib import Path
import platform
import shutil
import stat
import subprocess
import sys
import tempfile
import uuid
import signal

def interrupted(signum, frame):
    raise KeyboardInterrupt

signal.signal(signal.SIGTERM, interrupted)

VERSION = "1.0.0"

def safe(path, directory=False):
    p = Path(os.path.abspath(os.path.expanduser(str(path))))
    home = Path.home().resolve()
    if p == home or home not in p.parents:
        raise ValueError("Managed paths must be strictly inside the current user's home")
    for part in [p, *p.parents]:
        if part.is_symlink():
            raise ValueError("Symbolic links are not allowed in managed paths")
    if p.exists():
        if p.stat().st_uid != os.getuid():
            raise ValueError("Managed path is not owned by the current user")
        if not (p.is_file() or p.is_dir()):
            raise ValueError("Special files are not supported")
    return p

def validate_tree(p):
    safe(p)
    if p.is_file() and p.stat().st_nlink != 1:
        raise ValueError("Hard links are not supported")
    if p.is_dir():
        for root, dirs, names in os.walk(p, followlinks=False):
            for name in dirs + names:
                q = safe(Path(root) / name)
                if q.is_file() and q.stat().st_nlink != 1:
                    raise ValueError("Hard links are not supported")

def digest(p):
    h = hashlib.sha256()
    with p.open('rb') as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b''):
            h.update(chunk)
    return h.hexdigest()

def inventory(p):
    validate_tree(p)
    if p.is_file():
        return {'.': digest(p)}
    return {str(q.relative_to(p)): digest(q) for q in sorted(p.rglob('*')) if q.is_file()}

def copy(src, dst):
    validate_tree(src)
    if src.is_dir():
        shutil.copytree(src, dst)
    else:
        shutil.copy2(src, dst)

def running():
    # Inspect executable names only, never command lines or credentials.
    for entry in Path('/proc').glob('[0-9]*/comm'):
        try:
            if 'navicat' in entry.read_text().lower():
                return True
        except (OSError, UnicodeError):
            pass
    return False

def stopped():
    if running():
        raise ValueError("Close Navicat before reading backups or changing application data")

def targets(a):
    base = safe(a.config_root)
    return [base / 'Common/connections.json', base / 'Premium/Profiles'] + [safe(x) for x in a.profile_path]

def backup(paths, state, kind='configuration'):
    stopped()
    name = datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ') + '-' + uuid.uuid4().hex
    pending = state / ('.pending-' + name)
    pending.mkdir(mode=0o700)
    entries = []
    try:
        for i, path in enumerate(paths):
            path = safe(path)
            exists = path.exists()
            entry = {'target': str(path), 'exists': exists, 'slot': str(i)}
            if exists:
                copy(path, pending / str(i))
                entry['hashes'] = inventory(pending / str(i))
            entries.append(entry)
        (pending / 'manifest.json').write_text(json.dumps({'version': 1, 'kind': kind, 'entries': entries}))
        result = state / name
        pending.rename(result)
        return result
    except BaseException:
        shutil.rmtree(pending)
        raise

def load_backup(path, allowed, state):
    path = safe(path)
    if path.parent != state:
        raise ValueError("Backup must be a direct child of this manager's state directory")
    validate_tree(path)
    data = json.loads((path / 'manifest.json').read_text())
    if data.get('version') != 1 or not isinstance(data.get('entries'), list):
        raise ValueError("Unsupported backup manifest")
    seen = set()
    for i, e in enumerate(data['entries']):
        dest = safe(e['target'])
        if dest not in allowed or dest in seen or e['slot'] != str(i) or type(e['exists']) is not bool:
            raise ValueError("Backup target does not match explicitly selected data paths")
        seen.add(dest)
        if e['exists'] and inventory(path / str(i)) != e['hashes']:
            raise ValueError("Backup integrity check failed")
    return data

def apply(path, data):
    for e in data['entries']:
        dst = safe(e['target'])
        validate_tree(dst)
        if dst.is_dir():
            shutil.rmtree(dst)
        elif dst.exists():
            dst.unlink()
        if e['exists']:
            dst.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
            copy(path / e['slot'], dst)

def restore(path, allowed, state):
    stopped()
    data = load_backup(path, allowed, state)
    recovery = backup([Path(e['target']) for e in data['entries']], state, 'rollback')
    # Journal is durable before the first change. Interrupted work can be rolled back.
    journal = state / 'rollback.json'
    journal.write_text(json.dumps({'backup': str(recovery)}))
    try:
        apply(Path(path), data)
    except BaseException:
        apply(recovery, load_backup(recovery, allowed, state))
        raise

def detect(a):
    executable = a.executable or shutil.which('navicat') or shutil.which('navicat-premium')
    print('OS:', platform.system(), platform.release(), 'Architecture:', platform.machine())
    print('Executable:', executable or 'Not found; use --executable PATH')
    print('Version: unknown (no unverified version flag is executed)')
    print('Installation:', 'AppImage candidate' if executable and executable.endswith('.AppImage') else 'Unknown/native launcher candidate')
    print('Navicat running:', running())
    for p in targets(a):
        print('Data:', p, 'present' if p.exists() else 'missing')
    return executable

def main():
    parser = argparse.ArgumentParser(description='Navicat data manager; never resets licensing. Close Navicat before backups and changes.')
    actions = parser.add_mutually_exclusive_group()
    for flag in ['detect', 'info', 'diagnose', 'analyze', 'backup', 'backup-connections', 'clean-cache', 'clean-temporary', 'permissions', 'launch', 'rollback']:
        actions.add_argument('--' + flag, action='store_true')
    actions.add_argument('--restore', metavar='BACKUP')
    actions.add_argument('--repair', metavar='BACKUP', help='Recover selected data from a verified manager backup')
    parser.add_argument('--version', action='version', version=VERSION)
    parser.add_argument('--config-root', default=str(Path(os.environ.get('XDG_CONFIG_HOME', str(Path.home() / '.config'))) / 'navicat'))
    parser.add_argument('--profile-path', action='append', default=[], help='Additional confirmed settings/profile directory')
    parser.add_argument('--cache-path', help='Explicit verified disposable Navicat cache directory')
    parser.add_argument('--temporary-path', help='Explicit verified disposable Navicat temporary directory')
    parser.add_argument('--executable', help='Explicit trusted Navicat executable; no shell expansion')
    parser.add_argument('--dry-run', action='store_true')
    parser.add_argument('--verbose', action='store_true')
    parser.add_argument('--yes', action='store_true', help='Confirm data changes')
    a = parser.parse_args()
    os.umask(0o077)
    if os.geteuid() == 0:
        raise ValueError('Run as your normal desktop user, not root')
    selected = targets(a)
    state = safe(Path(os.environ.get('XDG_STATE_HOME', str(Path.home() / '.local/state'))) / 'navicat-manager')
    if a.detect or a.info or a.diagnose or a.analyze:
        detect(a)
        if a.diagnose:
            print('Report excludes file contents, environment variables and command-line arguments. Save stdout to a private file if needed.')
        return
    if a.permissions:
        for p in selected:
            validate_tree(p)
            if p.exists():
                print(p, oct(stat.S_IMODE(p.stat().st_mode)), 'private' if p.stat().st_mode & 0o077 == 0 else 'review group/other access')
        return
    if a.launch:
        exe = detect(a)
        if not exe:
            raise ValueError('No executable selected')
        if not a.dry_run:
            subprocess.Popen([exe], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True)
        return
    clean = a.clean_cache or a.clean_temporary
    if clean:
        explicit = a.cache_path if a.clean_cache else a.temporary_path
        if not explicit:
            raise ValueError('An explicit verified disposable path is required')
        candidate = safe(explicit)
        base = safe(a.config_root)
        if candidate == base or candidate in base.parents or base in candidate.parents:
            raise ValueError('Cache cleanup cannot touch the configuration tree')
        for p in selected + [state]:
            if candidate == p or candidate in p.parents or p in candidate.parents:
                raise ValueError('Cleanup overlaps protected data')
        if not candidate.is_dir():
            raise ValueError('Cleanup target must be an existing directory')
        selected = [candidate]
    if not any([a.backup, a.backup_connections, a.restore, a.repair, clean, a.rollback]):
        parser.print_help()
        return
    for p in selected:
        validate_tree(p)
        if p == state or p in state.parents or state in p.parents:
            raise ValueError('State directory overlaps managed data')
    if a.dry_run:
        stopped()
        if a.restore or a.repair:
            load_backup(safe(a.restore or a.repair), selected, state)
        print('Dry run: no files or directories will be written.')
        print('Selected paths:', *(str(p) for p in selected), sep='\n')
        return
    state.mkdir(parents=True, exist_ok=True, mode=0o700)
    validate_tree(state)
    if stat.S_IMODE(state.stat().st_mode) & 0o077:
        raise ValueError('State directory must have mode 0700')
    import fcntl
    with (state / 'lock').open('a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        if a.backup or a.backup_connections:
            print('Backup:', backup(selected, state, 'connections' if a.backup_connections else 'configuration'))
            return
        if not a.yes:
            raise ValueError('Changes require --yes; first review with --dry-run')
        if clean:
            stopped()
            recovery = backup(selected, state, 'cache')
            (state / 'rollback.json').write_text(json.dumps({'backup': str(recovery)}))
            try:
                shutil.rmtree(selected[0])
                selected[0].mkdir(mode=0o700)
            except BaseException:
                apply(recovery, load_backup(recovery, selected, state))
                raise
        else:
            path = a.restore or a.repair
            if a.rollback:
                path = json.loads((state / 'rollback.json').read_text())['backup']
                # Cache rollback must be explicitly authorized with the original path.
                selected += [safe(x) for x in [a.cache_path, a.temporary_path] if x]
            restore(safe(path), selected, state)
        print('Operation completed. Recovery backup retained privately.')

def interactive():
    labels = ['Detect Navicat Installation', 'Display System Information', 'Analyze Configuration',
              'Backup Configuration', 'Backup Connection Profiles', 'Restore Configuration',
              'Clean Application Cache', 'Repair Configuration', 'Verify File Permissions',
              'Generate Diagnostic Report', 'Launch Navicat Premium', 'Rollback Previous Changes']
    flags = ['--detect', '--info', '--analyze', '--backup', '--backup-connections', '--restore',
             '--clean-cache', '--repair', '--permissions', '--diagnose', '--launch', '--rollback']
    while True:
        color = sys.stdout.isatty() and 'NO_COLOR' not in os.environ
        print(('\033[36m' if color else '') + '=' * 50)
        print('          NAVICAT PREMIUM LINUX MANAGER\n                    Version ' + VERSION)
        print('=' * 50 + ('\033[0m' if color else ''))
        for i, label in enumerate(labels, 1):
            print(f' [{i:2}] {label}')
        print(' [ 0] Exit')
        try:
            choice = input('Select: ').strip()
            if choice == '0':
                return
            index = int(choice) - 1
            if not 0 <= index < len(flags):
                raise ValueError('Invalid selection')
            args = [flags[index]]
            if choice in ('6', '8'):
                args += [input('Manager backup directory: ')]
            if choice == '7':
                args += ['--cache-path', input('Verified disposable cache directory: ')]
            if choice in ('6', '7', '8', '12'):
                if input('Type yes to confirm changes: ') != 'yes':
                    continue
                args += ['--yes']
            sys.argv[1:] = args
            main()
        except EOFError:
            return
        except (Exception, KeyboardInterrupt):
            print('Operation failed or canceled. Use CLI diagnostics to review paths and permissions.', file=sys.stderr)

if __name__ == '__main__':
    try:
        if len(sys.argv) == 1:
            interactive()
        else:
            main()
    except (Exception, KeyboardInterrupt) as exc:
        # Never print file contents, subprocess output, or arbitrary exception text.
        if isinstance(exc, ValueError):
            print('Error:', str(exc), file=sys.stderr)
        else:
            print('Operation failed (' + type(exc).__name__ + '). Check paths, permissions and backup integrity; use --rollback after interruption.', file=sys.stderr)
        sys.exit(1)

NAVICAT_MANAGER_PY
