#!/usr/bin/env zsh
if pgrep -xq "lo-rain" ; then
	killall "lo-rain"
else
	open -a "lo-rain"
fi
