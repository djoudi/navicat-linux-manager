setup() {
 export HOME="$BATS_TEST_TMPDIR/home with spaces"
 export XDG_CONFIG_HOME="$HOME/.config" XDG_STATE_HOME="$HOME/.local/state"
 mkdir -p "$HOME/.config/navicat/Common"
 SCRIPT="$BATS_TEST_DIRNAME/../navicat-manager.sh"
 printf original > "$HOME/.config/navicat/Common/connections.json"
}
