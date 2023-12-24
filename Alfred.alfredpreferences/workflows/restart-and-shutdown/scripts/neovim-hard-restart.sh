#!/usr/bin/env zsh
if killall -9 neovide nvim osascript "Automator Application Stub"; then
	delay 0.5
	echo -n "Force restarting neovim…" # Alfred notification
	open -a "Neovide"                  # config reopens last file if no arg
	osascript -e 'tell application "Neovide" to activate'
else
	echo -n "Could not kill neovide." # Alfred notification
fi
