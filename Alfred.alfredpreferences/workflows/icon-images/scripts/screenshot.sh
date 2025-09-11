#!/usr/bin/env zsh

location="/tmp/screenshots"

#───────────────────────────────────────────────────────────────────────────────

mkdir -p "$location"
timestamp=$(date +%Y-%m-%d_%H-%M-%S)
screenshot_file="$location/Screenshot_$timestamp.png"
screencapture -i "$screenshot_file"

echo -n "$screenshot_file" # pass to Alfred
