#!/usr/bin/env zsh
# shellcheck disable=2154
query="$*"
extra_args=$([[ "$noua" == "1" ]] && echo "--noua" || echo "")

# get URL
# shellcheck disable=2086
response=$(ddgr --unsafe $extra_args --num=1 --json --reg="$region" "$query")
url=$(echo "$response" | grep "url" | cut -d'"' -f4)

# If Discord, enclose URL in <>
front_app=$(osascript -e 'tell application "System Events" to set frontApp to (name of first process where it is frontmost)')
[[ "$front_app" == "Discord" ]] && url="<$url>"

# Copy & notify via Alfred
echo -n "$url" | pbcopy
echo -n "$url"
