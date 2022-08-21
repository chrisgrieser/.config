#!/usr/bin/env zsh
osascript -e '
	tell application "System Events"
		keystroke "a" using {command down}
		keystroke "c" using {command down}
	end tell'

sleep 0.1
pbpaste | $EDITOR | pbcopy
sleep 0.1

osascript -e 'tell application "System Events" to keystroke "v" using {command down}'

