#!/usr/bin/env zsh
FRONT_APP=$(osascript -e 'tell application "System Events" to return name of first process whose frontmost is true')
killall "$FRONT_APP"
while pgrep -q "$FRONT_APP" ; do sleep 0.1; done
open -a "$FRONT_APP"
