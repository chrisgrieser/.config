#!/usr/bin/env zsh
FRONT_APP=$(osascript -e 'tell application "System Events" to return name of first process whose frontmost is true')
killall "$FRONT_APP"
sleep 0.5
open -a "$FRONT_APP"
