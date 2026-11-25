# User guide

Run `--detect` and compare candidate locations with Navicat's Edit Connection >
Advanced > Settings Location and its Profiles Location. Supply custom directories
with repeated `--profile-path` flags. Close Navicat and run `--backup`.

Keep the printed backup directory. Review recovery with `--restore BACKUP
--dry-run`, then apply with `--yes`. Repair uses the same mechanism with
`--repair BACKUP --yes`. Corrupt data is backed up as opaque bytes, never silently
rewritten. No backup means no automatic schema repair is available.

For cross-machine or major-version migrations, prefer Navicat File > Export
Connections / Import Connections. The manager does not guarantee credential
portability or back up external keyrings and database servers.

`--rollback --yes` uses the most recent recovery snapshot. Cache/temp rollback
also needs its original explicit path. Repeated rollback toggles between the
last two states; select an older backup explicitly to restore older history.
Backups must be direct children of the manager state directory.

`--permissions` reports root path access without changing ownership or modes.
`--diagnose` prints a bounded report to stdout. Save privately with
`umask 077; navicat-manager --diagnose > diagnostic.txt` and review local paths
before sharing. No persistent logs are automatically created.

`--launch --executable PATH` directly executes a trusted binary without shell
parsing or extra arguments. `--dry-run` prevents launch and state writes.
`--version` prints the manager version, not Navicat's version.
