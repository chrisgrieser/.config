#!/usr/bin/env zsh

open -a "Twitter"
while ! pgrep -q "Twitter"; do sleep 0.1; done
osascript -e 'tell application "System Events" to keystroke "n" using {command down}'
