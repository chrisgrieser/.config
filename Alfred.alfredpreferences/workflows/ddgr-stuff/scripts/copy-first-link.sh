#!/usr/bin/env zsh
# shellcheck disable=2154,2086
query="$*"
extra_args=$([[ "$noua" == "1" ]] && echo "--noua" || echo "")

# get URL
# using older version https://github.com/jarun/ddgr/blob/15f91df06079847143f5915e53fe6e7c588da80d/ddgr
# using older version PENDING https://github.com/jarun/ddgr/issues/159
response=$(python3 ./binary/ddgr.py --unsafe $extra_args --num=1 --json --reg="$region" "$query")
url=$(echo "$response" | grep "url" | cut -d'"' -f4)

# If Discord, enclose URL in <>
front_app=$(osascript -e 'tell application "System Events" to set frontApp to (name of first process where it is frontmost)')
[[ "$front_app" == "Discord" ]] && url="<$url>"

# Copy & notify via Alfred
echo -n "$url" | pbcopy
echo -n "$url"
