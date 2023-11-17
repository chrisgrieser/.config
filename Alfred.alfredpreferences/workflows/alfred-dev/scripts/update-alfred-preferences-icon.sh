#!/usr/bin/env zsh
# shellcheck disable=2154 # set via Alfred

if ! command -v fileicon &>/dev/null; then
	echo "fileicon not installed."
	return 1
fi

pref_path="/Applications/Alfred 5.app/Contents/Preferences/Alfred Preferences.app"
icon_path="./Alfred Preferences.icns"
fileicon set "$pref_path" "$icon_path" &>/dev/null && echo "updated"
