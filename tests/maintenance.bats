#!/usr/bin/env bats
load helper.bash
@test "reject unsafe cache" {
 run bash "$SCRIPT" --clean-cache --cache-path "$HOME/.config" --yes
 [ "$status" -eq 1 ]
}
@test "require explicit cache" {
 run bash "$SCRIPT" --clean-cache --yes
 [ "$status" -eq 1 ]
}
@test "cache cleanup is repeatable and rollback restores data" {
 mkdir "$HOME/cache"
 printf disposable > "$HOME/cache/item"
 run bash "$SCRIPT" --clean-cache --cache-path "$HOME/cache" --yes
 [ "$status" -eq 0 ]
 [ ! -e "$HOME/cache/item" ]
 run bash "$SCRIPT" --rollback --cache-path "$HOME/cache" --yes
 [ "$status" -eq 0 ]
 [ "$(cat "$HOME/cache/item")" = disposable ]
 run bash "$SCRIPT" --clean-cache --cache-path "$HOME/cache" --yes
 [ "$status" -eq 0 ]
 run bash "$SCRIPT" --clean-cache --cache-path "$HOME/cache" --yes
 [ "$status" -eq 0 ]
}
