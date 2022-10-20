#!/usr/bin/env zsh

FILE_TO_MOVE="$*"

FRONT_APP=$(osascript -e 'tell application "System Events" to set frontApp to (name of first process where it is frontmost)')

if [[ "$FRONT_APP" =~ "Finder" ]]; then
	TARGET_DIR=$(osascript -e 'tell application "Finder"
		if (count windows) is not 0 then set pathToOpen to target of window 1 as alias
		return POSIX path of pathToOpen
	end tell')
elif [[ "$FRONT_APP" =~ "Marta" ]]; then
	TARGET_DIR=$(osascript -e 'tell 
		if (count windows) is not 0 then set pathToOpen to target of window 1 as alias
		return POSIX path of pathToOpen
	end tell')
fi
[[ -d "$TARGET_DIR" ]] || exit 1
