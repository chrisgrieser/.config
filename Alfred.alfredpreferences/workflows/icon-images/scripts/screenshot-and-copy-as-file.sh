#!/usr/bin/env zsh
# shellcheck disable=2154 # Alfred environment variables

mkdir -p "$screenshot_folder"
timestamp=$(date +%Y-%m-%d_%H-%M-%S)
file="$screenshot_folder/Screenshot_$timestamp.png"
screencapture -i "$file"
[[ -f "$file" ]] || exit 1 # screenshot aborted
osascript -e "tell application \"Finder\" to set the clipboard to (POSIX file \"$file\")"
