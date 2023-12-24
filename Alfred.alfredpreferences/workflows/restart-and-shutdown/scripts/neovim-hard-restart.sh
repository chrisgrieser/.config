#!/usr/bin/env zsh
if killall -9 neovide nvim osascript "Automator Application Stub"; then
	delay 0.3
	echo -n "Force restarting neovim…" # Alfred notification
	osascript -e 'tell application "Neovide" to activate' # `open -a` does not focus properly
else
	echo -n "Could not kill neovide." # Alfred notification
fi
