#!/usr/bin/env zsh

appName=$(echo "$*" | sed -E 's/.*\/(.*).app/\1/' | sed 's/ /%20/' )
open -g "hammerspoon://split?app=$appName"


