#!/usr/bin/env zsh

if pgrep -x "Hammerspoon" > /dev/null; then
	killall "Hammerspoon"
	sleep 1
fi

open -a "Hammerspoon"
