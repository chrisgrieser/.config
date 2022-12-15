#!/usr/bin/env zsh

# has to be a separate script, since the next script is still considered active
# and therefore won't run before alacritty is quit.
if pgrep -q "alacritty"; then
	osascript -e 'tell application "Alacritty" to activate'
	echo -n "already-running"
fi
