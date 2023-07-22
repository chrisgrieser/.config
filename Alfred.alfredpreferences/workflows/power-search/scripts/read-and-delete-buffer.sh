#!/usr/bin/env zsh

# shellcheck disable=2154
file="$alfred_workflow_cache/urlsToOpen.txt"

[[ -e "$file" ]] || return 1
content=$(cat "$file")
rm "$file"
echo -n "$content"
