#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

if ! command -v ddgr &>/dev/null; then echo "ddgr not installed." && return 1; fi

query="$*"
url=$(ddgr --num=1 --json "$query" | grep "url" | cut -d'"' -f4)
echo -n "$url" | pbcopy
echo -n "$url" # notification via Alfred

