#!/usr/bin/env zsh

hash=$(echo "$*" | cut -d";" -f1)
FULL_PATH=$(echo "$*" | cut -d";" -f2)
line=$(echo "$*" | cut -d";" -f3)
FILE="$(basename "$FULL_PATH")"
EXT="${FILE##*.}"
OLD="/tmp/$hash.$EXT"

cd "$(dirname "$FULL_PATH")" || exit 1
[[ ! -e "$OLD" ]] && git show "$hash:./$FILE" > "$OLD"

alacritty --command nvim +$line "$OLD"
