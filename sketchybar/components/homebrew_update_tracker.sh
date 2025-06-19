#!/usr/bin/env zsh

# CONFIG
threshold=20

#───────────────────────────────────────────────────────────────────────────────

outdated=$(brew outdated --quiet | wc -l | tr -d " ")

if [[ $outdated -gt $threshold ]]; then
	sketchybar --set "$NAME" drawing=true label="$outdated"
else
	sketchybar --set "$NAME" drawing=false
fi
