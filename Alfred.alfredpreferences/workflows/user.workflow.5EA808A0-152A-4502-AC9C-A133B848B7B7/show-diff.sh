#!/usr/bin/env zsh

hash=$(echo "$*" | cut -d";" -f1)
FULL_PATH=$(echo "$*" | cut -d";" -f2)
FILE="$(basename "$FULL_PATH")"
EXT="${FILE##*.}"
OLD="/tmp/$hash.$EXT"

cd "$(dirname "$FULL_PATH")" || exit 1
[[ ! -e "$OLD" ]] && git show "$hash:./$FILE" > "$OLD"

diff --side-by-side --ignore-all-space "$OLD" "$FULL_PATH" | tail -n+3 > "/tmp/$hash.diff"

alacritty --command nvim "/tmp/$hash.diff"
