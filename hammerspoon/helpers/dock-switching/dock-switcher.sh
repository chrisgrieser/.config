#!/usr/bin/env zsh

data_store=$(dirname "$0")
mode="$1"
layout="$2"
dock_plist="$HOME/Library/Preferences/com.apple.dock.plist"
dock_config="$data_store/$layout.plist" 

#───────────────────────────────────────────────────────────────────────────────

if [[ "$mode" == "--load" ]]; then
	if [[ -z "$layout" ]] ; then
		echo "Layout to load is missing."
		return 1
	elif [[ ! -e "$dock_config" ]]; then
		echo "Layout '$layout' does not exist."
		return 1
	fi
	rm "$dock_plist" || return 1
	cp -a "$dock_config" "$dock_plist"
	defaults import com.apple.dock "$dock_plist"
	sleep 0.1
	killall Dock
	echo "Loaded layout '$layout'"
elif [[ "$mode" == "--save" ]]; then
	if [[ -z "$layout" ]] ; then
		echo "Layout to save is missing."
		return 1
	fi
	cp -f "$dock_plist" "$dock_config"
	echo "Saved as '$layout'"
else
	echo "Not a valid option."
	return 1
fi

