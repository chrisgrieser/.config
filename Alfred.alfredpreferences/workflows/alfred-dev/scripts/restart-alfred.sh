#!/usr/bin/env zsh
# INFO this script cannot be called directly from Alfred, since it would
# terminate itself. It must be called as a disowned process.
osascript -e 'display notification "" with title "Restarting Alfred…"'
killall -9 "Alfred"
while pgrep -xq "Alfred"; do sleep 0.1; done
sleep 0.1
open -a "Alfred 5"
osascript -e 'tell application id "com.runningwithcrayons.Alfred" to search'
