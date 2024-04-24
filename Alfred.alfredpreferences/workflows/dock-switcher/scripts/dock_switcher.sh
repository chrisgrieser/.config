#!/usr/bin/env zsh
layout="$1"

# shellcheck disable=2154 # Alfred var `mode` and `dock_layout_storage`
if [[ ! -d "$dock_layout_storage" ]]; then
	echo "⚠️ Layout storage directory does not exist."
	return 1
elif [[ -z "$layout" ]]; then
	echo "⚠️ No layout to save given."
	return 1
elif [[ "$mode" != "load" && "$mode" != "save" ]]; then
	echo "⚠️ Not a valid option."
	return 1
fi

#───────────────────────────────────────────────────────────────────────────────

# location where macOS stores the current layout
dock_plist="$HOME/Library/Preferences/com.apple.dock.plist"

layout_file="$dock_layout_storage/$layout.plist"
if [[ "$mode" == "load" ]]; then
	if [[ ! -f "$layout_file" ]]; then
		echo "⚠️ Layout \"$layout\" does not exist."
		return 1
	fi
	rm "$dock_plist" || return 1
	cp -a "$layout_file" "$dock_plist"
	defaults import com.apple.dock "$dock_plist"
	sleep 0.1
	killall Dock
	echo "✅ Loaded layout \"$layout\""
elif [[ "$mode" == "save" ]]; then
	cp -f "$dock_plist" "$layout_file"
	echo "✅ Saved as \"$layout\""
fi
