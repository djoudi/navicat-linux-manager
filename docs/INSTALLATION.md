# Installation

Run `chmod +x install.sh` then `./install.sh`. Code is installed in
`~/.local/lib/navicat-linux-manager`, with a symlink in `~/.local/bin`.
Add that bin directory to PATH. Existing destinations are refused.

Optional system installation: `sudo bash install.sh --system`. This uses
`/usr/local/lib/navicat-linux-manager` and `/usr/local/bin/navicat-manager`.
Run the manager itself as your desktop user.

Uninstall with `bash uninstall.sh`, or `sudo bash uninstall.sh --system` for the
system copy. The installation marker and expected symlink must match. Application
data and manager backups are retained. Uninstall before installing an upgrade.

For standalone use, copy `standalone/navicat-manager.sh` to your chosen bin
directory and make it executable. Remove that file manually to uninstall it.

Development checks:

```bash
shellcheck navicat-manager.sh install.sh uninstall.sh lib/*.sh standalone/navicat-manager.sh
bats tests
python3 -m unittest discover -s tests -p 'test_*.py'
```
