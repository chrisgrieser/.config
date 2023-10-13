#!/usr/bin/env zsh

FRONT_APP=$(osascript -e 'tell application "System Events" to set frontApp to (name of first process where it is frontmost)')
if [[ "$FRONT_APP" == "Finder" ]]; then
	dir_to_open=$(osascript -e 'tell application "Finder" to return POSIX path of (target of window 1 as alias)' | sed -E 's|/$||')
elif [[ "$FRONT_APP" == "neovide" ]]; then
	# INFO requires vim.opt.titlestring='%{expand(\"%:p\")}'
	win_title=$(osascript -e 'tell application "System Events" to tell process "neovide" to return name of front window')
	dir_to_open=$(dirname "$win_title")
fi

echo -n "$dir_to_open"
