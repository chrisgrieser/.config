#!/bin/zsh
# using full path makes this work even if `subl` hasn't been added to PATH
sublcli="/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl"

"$sublcli" --command copy_path
sleep 0.1
echo -n "$(pbpaste)"
