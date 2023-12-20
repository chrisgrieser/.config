#!/usr/bin/env zsh

FRONT_APP=$(osascript -e 'tell application "System Events" to set frontApp to (name of first process where it is frontmost)')
if [[ "$FRONT_APP" == "Finder" ]]; then
	dir_to_open=$(osascript -e 'tell application "Finder" to return POSIX path of (target of window 1 as alias)' | sed -E 's|/$||')
elif [[ "$FRONT_APP" == "neovide" ]]; then
	# INFO requires something like `vim.opt.titlestring = "%{getcwd()}"`
	dir_to_open=$(osascript -e 'tell application "System Events" to tell process "neovide" to return name of front window')
fi

echo -n "$dir_to_open"
