#!/usr/bin/env zsh
sublcli="/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" # using full path makes this work even if `subl` hasn't been added to PATH

hash=$(echo "$*" | cut -d";" -f1)
FULL_PATH=$(echo "$*" | cut -d";" -f2)
FILE="$(basename "$FULL_PATH")"
EXT="${FILE##*.}"
OLD="/tmp/$hash.$EXT"

cd "$(dirname "$FULL_PATH")" || exit 1
[[ ! -e "$OLD" ]] && git show "$hash:./$FILE" > "$OLD"

"$sublcli" "$OLD"
