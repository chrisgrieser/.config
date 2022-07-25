#!/usr/bin/env zsh

OLD=$(echo $* | cut -d";" -f1)
NEW=$(echo $* | cut -d";" -f2)

diff --unified --ignore-all-space "$*" old.js > patch.diff

sublcli="/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" # using full path makes this work even if `subl` hasn't been added to PATH

"$sublcli" "$*"
