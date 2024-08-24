#!/usr/bin/env zsh
# shellcheck disable=2012

filepath="$1"
current_flag=$(ls -lOd "$filepath" | awk '{print $5}')

new_flag=$([[ "$current_flag" == "hidden" ]] && echo "nohidden" || echo "hidden")
chflags "$new_flag" "$filepath"

osascript -e 'tell application "Finder" to tell front window to update every item'
