# Troubleshooting

- Missing installation: supply `--executable` for an AppImage outside PATH.
- Missing configuration: confirm Navicat UI paths and use `--config-root` or
  `--profile-path`. An absent-path backup is not proof of successful migration.
- Permission errors: use the desktop account. Inspect ownership manually; do not
  run the manager as root. Shared/external-home paths are unsupported.
- Corrupt configuration: back it up, then restore a known-good snapshot with
  `--repair`. Otherwise use official Navicat support/export tools.
- Running application: close all Navicat windows and background tasks. No process
  is killed automatically.
- Failed/interrupted changes: retain state and run `--rollback --yes` with the
  original config/profile/cache options. If recovery also fails, resolve storage
  or permission problems, then use the manifest to recover numbered backup slots.
- Hash mismatch: select an intact backup. Hashes detect accidental corruption,
  not a maliciously rewritten manifest.
- Lock error: wait for the other manager instance. Kernel locks release on exit.
- AppImage/FUSE or GUI startup failure: consult vendor installation documentation;
  this utility does not alter binaries, desktop dependencies or licensing.
