#!/usr/bin/env zsh

killall "Hammerspoon"
while pgrep -q "Hammerspoon"; do sleep 0.1 ; done
open -a "Hammerspoon"
