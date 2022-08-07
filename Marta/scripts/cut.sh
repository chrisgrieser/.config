#!/usr/bin/env zsh

input="$1"
[[ -d "$input" ]] && return 1 # applescript does not work for folders

file_name=$(basename "$input")
cp "$input" "/tmp/"
mv "$input" "$HOME/.Trash"
tempLocation="/tmp/$file_name"
osascript -e "set the clipboard to (POSIX file \"$tempLocation\")"

afplay "/System/Library/Sounds/Purr.aiff"
