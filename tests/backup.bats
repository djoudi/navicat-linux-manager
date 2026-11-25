#!/usr/bin/env bats
load helper.bash
@test "restore and rollback with spaces" {
 run bash "$SCRIPT" --backup
 [ "$status" -eq 0 ]
 snapshot=${output#Backup: }
 printf changed > "$HOME/.config/navicat/Common/connections.json"
 run bash "$SCRIPT" --restore "$snapshot" --yes
 [ "$status" -eq 0 ]
 [ "$(cat "$HOME/.config/navicat/Common/connections.json")" = original ]
 run bash "$SCRIPT" --rollback --yes
 [ "$status" -eq 0 ]
 [ "$(cat "$HOME/.config/navicat/Common/connections.json")" = changed ]
}
@test "tampered backup rejected" {
 run bash "$SCRIPT" --backup
 snapshot=${output#Backup: }
 printf tampered > "$snapshot/0"
 run bash "$SCRIPT" --restore "$snapshot" --yes
 [ "$status" -ne 0 ]
 [ "$(cat "$HOME/.config/navicat/Common/connections.json")" = original ]
}
@test "symlinks rejected" {
 rm "$HOME/.config/navicat/Common/connections.json"
 ln -s /etc/passwd "$HOME/.config/navicat/Common/connections.json"
 run bash "$SCRIPT" --backup
 [ "$status" -ne 0 ]
}
