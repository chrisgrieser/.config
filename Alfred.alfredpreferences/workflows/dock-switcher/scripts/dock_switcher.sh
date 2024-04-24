#!/usr/bin/env zsh
# shellcheck disable=2154

layout="$1"
if [[ ! -d "$dock_layout_storage" ]]; then
	echo "⚠️ Layout storage directory does not exist."
	return 1
elif [[ -z "$layout" ]]; then
	echo "⚠️ No layout to save given."
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
	killall Dock # = reloads Dock
	[[ -z "$silent" ]] && echo "✅ Loaded layout \"$layout\""
elif [[ "$mode" == "save" ]]; then
	cp -f "$dock_plist" "$layout_file"
	[[ -z "$silent" ]] && echo "✅ Saved as \"$layout\""
fi
