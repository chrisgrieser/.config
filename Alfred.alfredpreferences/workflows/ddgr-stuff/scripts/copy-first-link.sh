#!/usr/bin/env zsh
# shellcheck disable=2154
query="$*"

# get URL
response=$(ddgr --num=1 --unsafe --json --reg="$region" "$query")
url=$(echo "$response" | grep "url" | cut -d'"' -f4)

# If Discord, enclose URL in <>
front_app=$(osascript -e 'tell application "System Events" to set frontApp to (name of first process where it is frontmost)')
[[ "$front_app" == "Discord" ]] && url="<$url>"

# Copy & notify via Alfred
echo -n "$url" | pbcopy
echo -n "$url"
