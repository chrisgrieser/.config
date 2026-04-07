#!/usr/bin/env zsh

# delay to ensure count change was picked up
sleep 2
#-------------------------------------------------------------------------------
if [[ -n "$sketchybar_trigger_name" ]]; then
	if [[ ! -x "$(command -v sketchybar)" ]]; then
		echo "Could not update sketchybar component: sketchybar not installed." >&2
		return 1
	else
		sleep 2 # wait for sync
		sketchybar --trigger "$sketchybar_trigger_name"
	fi
fi
#-------------------------------------------------------------------------------
if [[ -n "$uri_trigger" ]]; then
	open -g "$uri_trigger"
fi
