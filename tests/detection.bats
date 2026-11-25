#!/usr/bin/env bats
load helper.bash
@test "detect" {
 run bash "$SCRIPT" --detect
 [ "$status" -eq 0 ]
}
@test "dry run" {
 run bash "$SCRIPT" --backup --dry-run
 [ "$status" -eq 0 ]
}
