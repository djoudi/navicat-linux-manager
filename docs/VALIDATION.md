# Validation record

Executed 2026-11-25 on Ubuntu 26.04 LTS x86_64 under WSL, as a normal user.
Python 3.14.4, Bats 1.13.0, ShellCheck 0.11.0.

- ShellCheck: passed on modular shell files, installers and standalone script.
- Bats: 9 tests passed. Detection, dry-run invocation, backup/restore/rollback with
  spaces, tampered snapshot rejection, symlink rejection, user install/launch/
  uninstall, unsafe cache refusal, explicit cache requirement, repeatable cache
  cleanup and cache rollback.
- Python unittest: 7 tests passed. Injected mid-restore failure, interrupted
  restore recovery, permission failure during backup, running-process refusal,
  manifest target allowlist, missing-path restoration, hardlink rejection.
- Python compilation: passed for the engine.
- Standalone `--version`: returned 1.0.0.

All data tests use synthetic fixtures. Interrupted restoration and permission
failure were injected, not power-cut or filesystem fault tests. Running-process
refusal was mocked, not exercised against an installed Navicat process.

Ubuntu 24.04, native desktop sessions, actual Navicat 17/18 installations,
AppImage GUI launch, sandbox discovery, real corrupt vendor schemas, external
credential stores, SIGKILL and power-loss durability remain untested. CI is
provided for Ubuntu 24.04 and 26.04 but has not been run on GitHub. Runner
availability must be confirmed there.
