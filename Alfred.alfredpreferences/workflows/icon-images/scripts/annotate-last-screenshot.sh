#!/usr/bin/env zsh

# shellcheck disable=SC2154 # Alfred variable
loc="$screenshot_folder"

# shellcheck disable=SC2012 # special chars not to be expected here
last_screenshot=$(ls -t "$loc" | head -n1)
if [[ -z "$last_screenshot" ]]; then
	echo "⚠️ No screenshots found."
else
	open -a "Preview" "$loc/$last_screenshot"
	osascript -e 'tell application "System Events" to tell process "Preview" 
		set frontmost to true 
		click menu item "Show Markup Toolbar" of menu "View" of menu bar 1 
	end tell' &> /dev/null
fi
