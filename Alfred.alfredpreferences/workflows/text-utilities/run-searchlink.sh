#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

if ! command -v ddgr &>/dev/null; then echo -n "ddgr not installed." && return 1; fi

query="$*"
link=$(ddgr --num=1 --noprompt --expand --nocolor "$query" | sed -n '2p' | xargs)
mdlink="[$query]($link)"
echo -n "$mdlink"
