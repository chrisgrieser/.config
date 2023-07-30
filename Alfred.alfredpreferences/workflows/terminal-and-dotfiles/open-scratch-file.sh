#!/usr/bin/env zsh

if pgrep -xq "neovide"; then
	nvim --server "/tmp/nvim_server.pipe"
	osascript -e 'tell application "Neovide" to activate'
else
	neovide --geometry=104x33 --notabs "$@" &
	disown # https://stackoverflow.com/a/20338584/22114136
fi

# paste from system clipboard
nvim --server "/tmp/nvim_server.pipe" --remote-send '"+p'
