#!/usr/bin/env zsh
filepath=$1
#-------------------------------------------------------------------------------

# open "$filepath"
# PENDING https://github.com/neovide/neovide/issues/3482

#-------------------------------------------------------------------------------

# open directory in Finder
if [[ -d "$filepath" ]]; then
	open "$filepath"
	return 0
fi

# open file in Neovide
if ! pgrep -xq "neovide"; then
	open -a "Neovide"
	while ! pgrep -xq "neovide"; do sleep 0.1; done
	sleep 0.6
fi
open -a "Neovide" # focus it
nvim --server '/tmp/nvim_server.pipe' --remote-send "<cmd>edit $filepath<CR>"
