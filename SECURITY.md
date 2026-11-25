# Security assessment

No registration, trial, activation or updater paths are targeted. Built-in scope
is connections and profiles. Explicit paths are a user trust boundary: verify
their purpose; never point custom data or cache options at licensing or unrelated
files. Configuration is never executed as code.

Backups may contain credentials, SSH material, SQL and exports. They are not
encrypted. State roots use mode 0700 and umask 077; copied file modes may be
preserved within private parents. Use encrypted storage and your own retention
policy. Uninstall retains backups.

Managed paths must be inside the user's home and owned by that user. Symlinks,
special files, hard links and dangerous overlaps are rejected. Restore allowlists
targets and checks hashes; no archives are extracted. A lock serializes manager
mutations. Another process with the same UID could still race path checks: do not
run alongside untrusted same-user processes or change paths during operations.

There is no backup authenticity signature, encryption, fsync-based power-loss
guarantee, external keyring backup or database-server backup. Permission reporting
does not certify every nested ACL. Keep independent offline backups. Reports
include usernames/paths and should be reviewed before sharing.

Report vulnerabilities privately to the repository maintainer using the hosting
platform's private reporting feature when enabled. Never attach real connection
data, credentials or backups.
