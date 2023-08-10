#!/usr/bin/env zsh

if ! command -v fileicon &>/dev/null; then
	echo "fileicon not installed."
	return 1
fi

# shellcheck disable=2154 # set via Alfred
icon_path="$custom_icon_path"

if [[ ! -e "$icon_path" ]]; then
	echo "Icon not found."
	return 1
fi

pref_path="/Applications/Alfred 5.app/Contents/Preferences/Alfred Preferences.app"
fileicon set "$pref_path" "$icon_path" && echo "updated"
