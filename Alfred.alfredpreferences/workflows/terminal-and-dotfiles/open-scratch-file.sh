#!/usr/bin/env zsh

if pgrep -xq "neovide"; then
	osascript -e 'tell application "Neovide" to activate'
else
	open -a "Neovide"
	while ! pgrep -xq "neovide"; do sleep 0.1; done
	sleep 0.7 # ensure everything is loaded
fi

# INFO using my custom `:Scratch` user command
nvim --server "/tmp/nvim_server.pipe" --remote-send '<cmd>Scratch<CR>'
