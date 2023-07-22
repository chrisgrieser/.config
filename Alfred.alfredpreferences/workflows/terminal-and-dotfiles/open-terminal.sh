#!/usr/bin/env zsh

FRONT_APP=$(osascript -e 'tell application "System Events" to set frontApp to (name of first process where it is frontmost)')
if [[ "$FRONT_APP" == "Finder" ]]; then
	dir_to_open=$(osascript -e 'tell application "Finder" to return POSIX path of (target of window 1 as alias)' | sed -E 's|/$||')
elif [[ "$FRONT_APP" == "Obsidian" ]]; then
	open "obsidian://advanced-uri?commandid=workspace%253Acopy-path"
	sleep 0.1 # wait for clipboard
	relative_path=$(pbpaste)
	dir_to_open=$(dirname "$VAULT_PATH/$relative_path") # VAULT_PATH defined in .zshenv
	[[ -d "$dir_to_open" ]] || dir_to_open="" # fallback: nonexistent file
elif [[ "$FRONT_APP" == "neovide" ]]; then
	# INFO requires vim.opt.titlestring='%{expand(\"%:p\")}'
	win_title=$(osascript -e 'tell application "System Events" to tell process "neovide" to return name of front window')
	dir_to_open=$(dirname "$win_title")
fi

echo -n "$dir_to_open"
