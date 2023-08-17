#!/usr/bin/env zsh
# shellcheck disable=2154 # set via Alfred

if ! command -v fileicon &>/dev/null; then
	echo "fileicon not installed."
	return 1
fi

if [[ ! -e "$custom_pref_icon_path" ]]; then
	echo "Icon not found."
	return 1
fi

pref_path="/Applications/Alfred 5.app/Contents/Preferences/Alfred Preferences.app"
fileicon set "$pref_path" "$custom_pref_icon_path" &>/dev/null && echo "updated"
