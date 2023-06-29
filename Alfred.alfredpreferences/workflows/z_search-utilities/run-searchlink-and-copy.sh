#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

if ! command -v ddgr &>/dev/null; then echo "ddgr not installed." && return 1; fi

link=$(ddgr --num=1 --noprompt --expand --nocolor "$1" | sed -n '2p' | xargs)
echo -n "$link" | pbcopy
echo -n "$link" # notification via Alfred

