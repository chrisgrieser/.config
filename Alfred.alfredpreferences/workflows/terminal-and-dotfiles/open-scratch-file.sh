#!/usr/bin/env zsh

if pgrep -xq "neovide"; then
	osascript -e 'tell application "Neovide" to activate'
else
	neovide --geometry=104x33 --notabs "$@" &
	disown # https://stackoverflow.com/a/20338584/22114136
	while ! pgrep -xq "neovide"; do sleep 0.1; done
	sleep 0.1
fi

# https://neovim.io/doc/user/remote.html#remote.txt
# new file, nowrite-file, paste from system clipboard
nvim --server "/tmp/nvim_server.pipe" \
	--remote-send '<cmd>enew | set buftype=nowrite | file Scratchpad<CR>"+p'
