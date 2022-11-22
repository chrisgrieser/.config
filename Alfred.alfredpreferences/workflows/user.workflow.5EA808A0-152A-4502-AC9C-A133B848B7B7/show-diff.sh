#!/usr/bin/env zsh

HASH=$(echo "$*" | cut -d";" -f1)
FULL_PATH=$(echo "$*" | cut -d";" -f2)
FILE="$(basename "$FULL_PATH")"
EXT="${FILE##*.}"
OLD="/tmp/$HASH.$EXT"

cd "$(dirname "$FULL_PATH")" || exit 1
[[ ! -e "$OLD" ]] && git show "$HASH:./$FILE" > "$OLD"

diff --side-by-side --ignore-all-space "$OLD" "$FULL_PATH" | tail -n+3 > "/tmp/$HASH.diff"

alacritty --command nvim "/tmp/$HASH.diff"
