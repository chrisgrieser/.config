#!/bin/zsh
# shellcheck disable=SC2154
export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH

WD="${working_directory/#\~/$HOME}"

# if file path was passed, use that as working directory
FINDER_PATH=$(osascript -e "if frontmost of application \"Finder\" then
	tell application \"Finder\"
		if (count windows) is not 0 then set pathToOpen to target of Finder window 1 as alias
		return POSIX path of pathToOpen
	end tell
end if")
[[ $FINDER_PATH ]] && WD="$FINDER_PATH"

DEVICE_NAME=$(scutil --get ComputerName)
if [[ "$DEVICE_NAME" =~ "Mac mini" ]] ; then
	# wider width of alacritty window on work computer
	nohup alacritty --option=window.dimensions.columns=99 --option=window.padding.x=8 --working-directory="$WD" &
elif [[ "$DEVICE_NAME" =~ "iMac" ]] ; then
	nohup alacritty --working-directory="$WD" &
else
	nohup alacritty &
fi

