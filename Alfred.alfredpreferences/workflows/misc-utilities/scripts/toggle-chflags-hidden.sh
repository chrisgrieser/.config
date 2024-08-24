#!/usr/bin/env zsh
# shellcheck disable=2012

filepath="$1"

# toggle hidden
current_flag=$(ls -lOd "$filepath" | awk '{print $5}')
new_flag=$([[ "$current_flag" == "hidden" ]] && echo "nohidden" || echo "hidden")
chflags "$new_flag" "$filepath"

# force reload window
osascript -e 'tell application "Finder" to close front window'
open -R "$filepath"

# notify via Alfred
echo "$(basename "$filepath") set to \"$new_flag\""
