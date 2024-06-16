#!/usr/bin/env zsh

# shellcheck disable=2154 # set by Alfred
if [[ "$focusedapp" == "com.apple.finder" ]]; then
	dir_to_open=$(osascript -e 'tell application "Finder" to return POSIX path of (target of window 1 as alias)' | sed -E 's|/$||')
elif [[ "$focusedapp" == "com.neovide.neovide" ]]; then
	# INFO requires something like `vim.opt.titlestring = "%{getcwd()}"`
	dir_to_open=$(osascript -e 'tell application "System Events" to tell process "neovide" to return name of front window')
elif [[ "$focusedapp" == "com.runningwithcrayons.Alfred-Preferences" ]]; then
	# https://www.alfredforum.com/topic/18390-get-currently-edited-workflow-uri/
	workflow_id=$(sed -n "4p" "$HOME/Library/Application Support/Alfred/history.json" | cut -d'"' -f2)
	prefs_location=$(grep "current" "$HOME/Library/Application Support/Alfred/prefs.json" | cut -d'"' -f4 | sed -e 's|\\/|/|g' -e "s|^~|$HOME|")
	dir_to_open="$prefs_location/workflows/$workflow_id"
fi

echo -n "$dir_to_open"
