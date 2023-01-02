#!/usr/bin/env zsh

# INFO to prevent constantly calling `git status`, which prevents other git processes
# from running due to lock (happens sometimes even with optional locks)
# FROM_PATCHWATCHER gets set when called from hammerspoon.
# WARN running a git command on a path watcher trigger leads to an infinite loop
# since git commands create index lock files, which again trigger the path
# watcher, therefore this workaround seems necessary
if [[ "$DIRTY" -eq 1 ]]; then
	icon="🔁"
elif [[ "$DIRTY" -eq 2 ]]; then
	icon="repo-path wrong"
else
	icon=""
fi
sketchybar --set "$NAME" icon="$icon"
