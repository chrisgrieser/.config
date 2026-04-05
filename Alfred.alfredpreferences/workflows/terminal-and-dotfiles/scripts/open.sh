#!/usr/bin/env zsh

# open "$1"

# PENDING https://github.com/neovide/neovide/issues/3444#issuecomment-4188793273
if ! pgrep -xq "neovide"; then
	open -a "Neovide"
	while ! pgrep -xq "neovide"; do sleep 0.1; done
	sleep 0.6
fi
open -a "Neovide" # focus it
nvim --server '/tmp/nvim_server.pipe' --remote-send "<cmd>edit $1<CR>"
