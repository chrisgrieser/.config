#!/usr/bin/env zsh
[[ -z "$sketchybar_trigger_name" ]] && return 0

# wait for sync
sleep 0.5

# shellcheck disable=2154 # Alfred variable
sketchybar --trigger "$sketchybar_trigger_name"
