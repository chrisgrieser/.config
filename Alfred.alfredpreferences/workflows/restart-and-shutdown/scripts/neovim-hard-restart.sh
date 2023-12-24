#!/usr/bin/env zsh
if killall -9 neovide nvim osascript "Automator Application Stub"; then
	sleep 0.2
	echo -n "Force restarting neovim…" # Alfred notification
	open -a "Neovide"
	sleep 0.1
	osascript -e 'tell application "Neovide" to activate' # `open -a` does not focus properly
else
	echo -n "Could not kill neovide." # Alfred notification
fi
