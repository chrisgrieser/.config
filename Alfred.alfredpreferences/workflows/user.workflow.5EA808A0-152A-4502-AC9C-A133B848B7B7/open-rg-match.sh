#!/bin/zsh
sublcli="/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" # using full path makes this work even if `subl` hasn't been added to PATH

"$sublcli" "$*"

