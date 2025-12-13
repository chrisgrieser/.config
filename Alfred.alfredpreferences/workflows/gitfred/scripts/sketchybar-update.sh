#!/usr/bin/env zsh
[[ -z "$sketchybar_trigger_name" ]] && return 0

if [[ ! -x "$(command -v sketchybar)" ]]; then
	echo "Could not update sketchybar component: sketchybar not installed." >&2
	return 1
else
	sleep 4 # wait for sync
	sketchybar --trigger "$sketchybar_trigger_name"
fi
