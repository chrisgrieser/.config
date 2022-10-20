#!/usr/bin/env zsh

FILE_TO_MOVE="$*"

FRONT_APP=$(osascript -e 'tell application "System Events" to set frontApp to (name of first process where it is frontmost)')

if [[ "$FRONT_APP" =~ "Finder" ]]; then
	TARGET_DIR=$(osascript -e 'tell application "Finder"
		if (count windows) is not 0 then set pathToOpen to target of window 1 as alias
		return POSIX path of pathToOpen
	end tell')
elif [[ "$FRONT_APP" =~ "Marta" ]]; then
	TARGET_DIR=$(osascript -e '
		tell application "System Events" to set martaProcess to first process whose name is "Marta"
		tell martaProcess to return name of front window
	')
	TARGET_DIR=${TARGET_DIR:11:-1}
fi

[[ -d "$TARGET_DIR" ]] || exit 1

mv "$FILE_TO_MOVE" "$TARGET_DIR"
