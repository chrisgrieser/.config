#!/bin/zsh
# using full path makes this work even if `subl` hasn't been added to PATH
sublcli="/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl"

query="$*"

[[ -z "$query" ]] && exit 1 # no selection guard clause

"$sublcli" "$query"

# if directory, then show sidebar
[[ -d "$query" ]] &&	"$sublcli" --command toggle_side_bar
