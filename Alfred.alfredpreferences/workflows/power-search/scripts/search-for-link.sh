#!/usr/bin/env zsh

if ! command -v ddgr &>/dev/null; then echo -n "ddgr not installed." && return 1; fi

query="$*"
url=$(ddgr --num=1 --json "$query" | grep "url" | cut -d'"' -f4)
mdlink="[$query]($url)"
echo -n "$mdlink"
