#!/usr/bin/env zsh
# shellcheck disable=2154
query="$*"

# get URL
# shellcheck disable=2086
response=$(ddgr $ddgr_args --num=1 --json --reg="$region" "$query")
url=$(echo "$response" | grep "url" | cut -d'"' -f4)

# If Discord, enclose URL in <>
front_app=$(osascript -e 'tell application "System Events" to set frontApp to (name of first process where it is frontmost)')
[[ "$front_app" == "Discord" ]] && url="<$url>"

# Copy & notify via Alfred
echo -n "$url" | pbcopy
echo -n "$url"
