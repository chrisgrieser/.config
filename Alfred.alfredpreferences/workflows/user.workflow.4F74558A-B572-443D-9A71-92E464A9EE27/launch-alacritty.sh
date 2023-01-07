#!/usr/bin/env zsh
# shellcheck disable=SC2154,SC2009
export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH
#───────────────────────────────────────────────────────────────────────────────

FRONT_APP=$(osascript -e 'tell application "System Events" to set frontApp to (name of first process where it is frontmost)')
if [[ "$FRONT_APP" =~ "Finder" ]]; then
	WD=$(osascript -e 'tell application "Finder"
		if (count windows) is not 0 then set pathToOpen to target of window 1 as alias
		return POSIX path of pathToOpen
	end tell')
	[[ -d "$WD" ]] || exit 1
elif [[ "$FRONT_APP" =~ "neovide" ]]; then
	win_title=$(osascript -e 'tell application "System Events" to tell process "neovide" to return name of front window')
	# INFO requires vim.opt.titlestring='%{expand(\"%:p\")}'
	WD=$(dirname "$win_title")
else
	WD="${working_directory/#\~/$HOME}"
fi

nohup alacritty --working-directory="$WD" &
