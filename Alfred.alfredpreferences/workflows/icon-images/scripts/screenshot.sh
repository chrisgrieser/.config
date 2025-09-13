#!/usr/bin/env zsh

location="/tmp/screenshots"

#───────────────────────────────────────────────────────────────────────────────

mkdir -p "$location"
timestamp=$(date +%Y-%m-%d_%H-%M-%S)
screenshot_file="$location/Screenshot_$timestamp.png"
screencapture -i "$screenshot_file"

[[ -f "$screenshot_file" ]] || exit 1 # screenshot aborted
