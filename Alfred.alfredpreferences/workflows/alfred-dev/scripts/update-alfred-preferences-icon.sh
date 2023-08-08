#!/usr/bin/env zsh

if ! command -v fileicon &>/dev/null; then print "\033[1;33mfileicon not installed.\033[0m" && return 1; fi

# shellcheck disable=2154 # set via Alfred
icon_path="$custom_icon_path"

pref_path="/Applications/Alfred 5.app/Contents/Preferences/Alfred Preferences.app"
fileicon set "$pref_path" "$icon_path" && echo "updated"
