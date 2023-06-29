#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

if ! command -v ddgr &>/dev/null; then echo "ddgr not installed." && return 1; fi

query="$*"
link=$(ddgr --num=1 --json --expand --nocolor "$query" | grep "url" | cut -d'"' -f4)
echo -n "$link" | pbcopy
echo -n "$link" # notification via Alfred

