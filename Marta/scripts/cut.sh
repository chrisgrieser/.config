#!/usr/bin/env zsh

input="$1"
[[ -f "$input" ]] || return 1 # this script does not work for folders or multiple files

file_name=$(basename "$input")
cp "$input" "/tmp/"
mv "$input" "$HOME/.Trash"
tempLocation="/tmp/$file_name"
osascript -e "set the clipboard to (POSIX file \"$tempLocation\")"

afplay "/System/Library/Sounds/bottle.aiff"
