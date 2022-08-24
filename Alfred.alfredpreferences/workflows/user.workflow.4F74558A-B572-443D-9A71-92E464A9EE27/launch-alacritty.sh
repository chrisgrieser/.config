#!/bin/zsh
# shellcheck disable=SC2154,SC2009
export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH

# if Finder or Sublime are frontmost, use those paths as working directory
# (same is done from inside Marta, so not needed to be done here)
FRONT_APP=$(osascript -e 'tell application "System Events" to set frontApp to (name of first process where it is frontmost)')
if [[ "$FRONT_APP" =~ "Finder" ]]; then
	WD=$(osascript -e 'tell application "Finder"
		if (count windows) is not 0 then set pathToOpen to target of window 1 as alias
		return POSIX path of pathToOpen
	end tell')
	[[ -d "$WD" ]] || exit 1
elif [[ "$FRONT_APP" =~ "sublime_text" ]]; then
	"/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" --command copy_path # using full path makes this work even if `subl` hasn't been added to PATH
	sleep 0.1
	WD=$(dirname "$(pbpaste)")
else
	WD="${working_directory/#\~/$HOME}"
fi

nohup alacritty --working-directory="$WD" &
exit
