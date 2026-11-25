#!/usr/bin/env bats
load helper.bash
@test "user install launch and uninstall" {
 run bash "$BATS_TEST_DIRNAME/../install.sh"
 [ "$status" -eq 0 ]
 run "$HOME/.local/bin/navicat-manager" --version
 [ "$status" -eq 0 ]
 [ "$output" = 1.0.0 ]
 run bash "$BATS_TEST_DIRNAME/../uninstall.sh"
 [ "$status" -eq 0 ]
 [ ! -e "$HOME/.local/bin/navicat-manager" ]
 [ -f "$HOME/.config/navicat/Common/connections.json" ]
}
