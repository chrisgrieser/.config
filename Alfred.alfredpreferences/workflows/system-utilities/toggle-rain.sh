#!/usr/bin/env zsh
if pgrep -x "lo-rain" ; then
	killall "lo-rain"
else
	open -a "lo-rain"
fi
