#!/usr/bin/env zsh
[[ -z "$sketchybar_trigger_name" ]] && return 0

# wait for sync
sleep 4

if [[ ! -x "$(command -v sketchybar)" ]]; then
	echo "Could not update sketchybar component: sketchybar not installed." >&2
	return 1
fi

# shellcheck disable=2154 # Alfred variable
sketchybar --trigger "$sketchybar_trigger_name"
