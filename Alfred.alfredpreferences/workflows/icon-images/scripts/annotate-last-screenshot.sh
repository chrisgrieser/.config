#!/usr/bin/env zsh
#-------------------------------------------------------------------------------

if [[ -z "$1" ]]; then
	# last screenshot
	screenshot_filename=$(ls -t "$screenshot_folder" | head -n1) # shuck: ignore=C006 # Alfred variable
	if [[ -z "$screenshot_file" ]]; then
		echo "⚠️ No screenshots found."
		return 1
	fi
	screenshot_file="$screenshot_folder/$screenshot_filename"
else
	# screenshot from script filter
	screenshot_file="$1"
fi

#-------------------------------------------------------------------------------

open -a "Preview" "$screenshot_file"
osascript -e 'tell application "System Events" to tell process "Preview"
		set frontmost to true
		click menu item "Show Markup Toolbar" of menu "View" of menu bar 1
	end tell' &>/dev/null
