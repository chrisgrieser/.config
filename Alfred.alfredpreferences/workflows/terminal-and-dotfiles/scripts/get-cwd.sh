#!/usr/bin/env zsh
# shellcheck disable=2154 # set by Alfred
#───────────────────────────────────────────────────────────────────────────────

if [[ "$focusedapp" == "com.apple.finder" ]]; then
	dir_to_open=$(osascript -e 'tell application "Finder" to return POSIX path of (target of window 1 as alias)' | sed -E 's|/$||')

elif [[ "$focusedapp" == "md.obsidian" ]]; then
	vault_location="$HOME/Vaults/" # CONFIG
	win_title=$(osascript -e 'tell application "System Events" to tell process "Obsidian" to return name of front window')
	vault_name=$(echo "$win_title" | sed -E 's|.* - (.*) - .*|\1|')
	dir_to_open="$vault_location/$vault_name"

elif [[ "$focusedapp" == "com.neovide.neovide" ]]; then
	# # REQUIRED `vim.opt.titlestring = "%{expand('%')}"` im nvim config
	current_file=$(osascript -e 'tell application "System Events" to tell process "neovide" to return name of front window')
	dir_to_open=$(dirname "$current_file")

fi

# INFO "Alfred Preferences.app" already covered by Alfred workflow devtools

# pass to Alfred action that opens the directory in the configured terminal
echo -n "$dir_to_open"
