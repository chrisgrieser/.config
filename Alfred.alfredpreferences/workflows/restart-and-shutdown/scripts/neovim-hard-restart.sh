#!/usr/bin/env zsh
if killall -9 neovide nvim osascript; then
	delay 0.5
	echo -n "Force restarting neovim…" # Alfred notification
	open -a "Neovide"                  # config reopens last file if no arg
else
	echo -n "Could not kill neovide." # Alfred notification
fi
