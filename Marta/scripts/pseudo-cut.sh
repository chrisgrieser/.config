#!/usr/bin/env zsh

# input="$1"

input="/Users/chrisgrieser/Library/Mobile Documents/com~apple~CloudDocs/File Hub/red"

[[ -d "$input" ]] && return 1 # applescript does not work for folders

file_name=$(basename "$input")
cp "$input" "/tmp/"
mv "$input" "$HOME/.Trash"
tempLocation="/tmp/$file_name"
osascript -e "set the clipboard to (POSIX file \"$tempLocation\")"

