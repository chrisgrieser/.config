#!/bin/zsh
# shellcheck disable=SC2154,SC2009
export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH

# Alacritty already open (pgrep does not work here)
if ps aux | grep "alacritty" &> /dev/null ; then
	open -a "alacritty"
	exit 0
fi

# if Finder or Sublime are frontmost, use those paths as working directory
# (same is done from inside Marta, so not needed to be done here)
FRONT_APP=$(osascript -e 'tell application "System Events" to set frontApp to (name of first process where it is frontmost)')
echo $FRONT_APP
if [[ "$FRONT_APP" == "Finder" ]]; then
	WD=$(osascript -e 'tell application "Finder"
		if (count windows) is not 0 then set pathToOpen to target of window 1 as alias
		return POSIX path of pathToOpen
	end tell')
	[[ -d "$WD" ]] && exit 1
elif [[ "$FRONT_APP" == "Sublime Text" ]]; then
	# using full path makes this work even if `subl` hasn't been added to PATH
	"/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" --command copy_path
	sleep 0.1
	WD=$(dirname "$(pbpaste)")
else
	WD="${working_directory/#\~/$HOME}"
fi

DEVICE_NAME=$(scutil --get ComputerName)
if [[ "$DEVICE_NAME" =~ "Mac mini" ]] ; then
	# wider width of alacritty window on work computer
	nohup alacritty --option=window.dimensions.columns=99 --option=window.padding.x=8 --working-directory="$WD" &
elif [[ "$DEVICE_NAME" =~ "iMac" ]] ; then
	nohup alacritty --working-directory="$WD" &
else
	nohup alacritty &
fi

