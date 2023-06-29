#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

if ! command -v ddgr &>/dev/null; then echo -n "ddgr not installed." && return 1; fi

query="$*"
url=$(ddgr --num=1 --json "$query" | grep "url" | cut -d'"' -f4)
mdlink="[$query]($url)"
echo -n "$mdlink"
