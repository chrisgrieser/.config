#!/usr/bin/env zsh

# WARN running a git command on a path watcher trigger leads to an infinite loop
# since git commands create index lock files, which again trigger the path
# watcher, therefore this workaround seems necessary

if [[ "$DIRTY" -eq 1 ]]; then
	icon="🔁"
else
	icon=""
fi
sketchybar --set "$NAME" icon="$icon"
