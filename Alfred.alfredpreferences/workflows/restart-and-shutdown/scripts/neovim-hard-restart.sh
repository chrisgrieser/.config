#!/usr/bin/env zsh
if killall -9 neovide nvim osascript; then
	delay 0.7
	echo -n "Force restarting neovim…" # Alfred notification
	open -a "Neovide"                  # config reopens last file if no arg
fi
