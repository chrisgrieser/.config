#!/usr/bin/env zsh
outdated=$(brew outdated --quiet | wc -l | tr -d " ")
threshold=30

# only show menubar item above threshold
if [[ $outdated -gt $threshold ]]; then
	sketchybar --set "$NAME" drawing=true label="$outdated"
else
	sketchybar --set "$NAME" drawing=false
fi
