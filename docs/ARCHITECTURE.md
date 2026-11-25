# Investigation and architecture

The original Windows batch deletes Update registry data, values within
Registration keys, and whole CLSID keys containing Info or ShellFolder. It has
no backup or safe application scoping. Registration changes affect licensing;
broad CLSID deletion can affect unrelated programs. None is replicated here.

## Vendor evidence

- [Linux installation](https://help.navicat.com/hc/en-us/articles/217789018-How-can-I-install-Navicat-on-Linux)
  documents the Navicat 17 x86_64 AppImage.
- [Navicat 18 Linux installation](https://www.navicat.com/manual/online_manual/en/navicat_18/linux_manual/installation.html)
  has search-indexed AppImage instructions; the full page fetch timed out during investigation.
- [Connection storage](https://help.navicat.com/hc/en-us/articles/219566088-How-secure-is-Navicat)
  documents the Linux example `~/.config/navicat/Common/connections.json`, versus
  the Windows Registry. This older article does not verify every future version.
- [Migration and profiles](https://help.navicat.com/hc/en-us/articles/218281627-How-to-get-the-connection-information-when-migrating-Navicat-to-new-computer)
  documents `~/.config/navicat/Premium/Profiles` and custom connection Settings Locations.
- [Workspace storage](https://help.navicat.com/hc/en-us/articles/360036036792-Where-are-the-workspace-files-stored)
  documents workspace files under Profiles.

No Navicat binary was installed for investigation. Existing paths are candidates,
not proof of application ownership or compatible schema. Cache, temporary and
log locations are unverified, so none is hardcoded. Version detection reports
unknown rather than executing an unverified version flag.

AppImages may be outside PATH and have portable home/config overrides. The
manager does not mount or extract them. A suffix identifies only a candidate
installation type. Native launchers are searched as `navicat` and
`navicat-premium`; other executables require an explicit trusted path. Sandbox,
portable and custom locations must be confirmed in the application UI. No Wine
prefix or Registry migration is attempted.

## Design and transaction limits

Bash exposes the requested modular API; Python provides validated filesystem
operations, SHA-256 inventories, locking and diagnostics. No external Python
packages are required. The standalone build embeds the same engine.
`config/default.conf` is documentation only and is never sourced.

Backups contain numbered data slots and a JSON manifest mapping original targets,
existence and file hashes. Missing paths are recorded. A directory rename
publishes a backup only after copying finishes. Restore validates hashes and
all targets against the invocation's allowlist before changing data.

Before mutation, a recovery backup and rollback journal are written. Caught
failures, KeyboardInterrupt and SIGTERM attempt rollback. SIGKILL cannot be
caught; use the journal through `--rollback` after interruption. This is not a
filesystem snapshot or fsync-backed power-loss transaction. Recovery failure
leaves backups available for manual recovery.

A manager flock serializes writes. It cannot prevent Navicat from starting
during a copy. Process detection reads `/proc/*/comm` only and can miss renamed
processes; keep the application closed. Cache cleanup uses recursive removal
only after path checks and a recovery backup. No whole-config reset or
speculative schema rewrite is performed. Repair restores a known-good backup.
