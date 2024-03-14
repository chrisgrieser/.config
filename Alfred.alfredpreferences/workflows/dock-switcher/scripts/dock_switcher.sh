#!/usr/bin/env zsh
mode="$1"
layout="$2"
dock_plist="$HOME/Library/Preferences/com.apple.dock.plist"

# shellcheck disable=2154
dock_config="$dock_layout_storage/$layout.plist"

#───────────────────────────────────────────────────────────────────────────────

if [[ "$mode" == "--load" ]]; then
	if [[ -z "$layout" ]]; then
		echo "Layout to load is missing."
	elif [[ ! -f "$dock_config" ]]; then
		echo "Layout '$layout' does not exist."
	else
		rm "$dock_plist" || return 1
		cp -a "$dock_config" "$dock_plist"
		defaults import com.apple.dock "$dock_plist"
		sleep 0.1
		killall Dock
		echo "✅ Loaded layout '$layout'"
	fi
elif [[ "$mode" == "--save" ]]; then
	if [[ -z "$layout" ]]; then
		echo "⚠️ Layout to save is missing."
	else
		cp -f "$dock_plist" "$dock_config"
		echo "✅ Saved as '$layout'"
	fi
else
	echo "⚠️ Not a valid option."
fi
