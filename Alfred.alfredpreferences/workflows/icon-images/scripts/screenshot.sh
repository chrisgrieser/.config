#!/usr/bin/env zsh

location="/tmp/screenshots"
timestamp=$(date +%Y-%m-%d_%H-%M-%S)
screenshot_file="$location/Screenshot_$timestamp.png"
screencapture -i "$screenshot_file"

osascript -e "tell application "Finder" to set the clipboard to '
		.. ("POSIX file %q"):format(path)"
