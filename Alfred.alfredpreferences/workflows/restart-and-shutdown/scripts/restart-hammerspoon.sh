#!/usr/bin/env zsh

killall "Hammerspoon"
while pgrep -xq "Hammerspoon"; do sleep 0.05 ; done
open -a "Hammerspoon"
