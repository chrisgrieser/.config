#!/usr/bin/env zsh
sublcli="/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" # using full path makes this work even if `subl` hasn't been added to PATH

OLD=$(echo "$*" | cut -d";" -f1)
NEW=$(echo "$*" | cut -d";" -f2)

diff --unified --ignore-all-space "$OLD" "$NEW" | tail -n+3 > "/tmp/patch.diff"

"$sublcli" "/tmp/patch.diff"
