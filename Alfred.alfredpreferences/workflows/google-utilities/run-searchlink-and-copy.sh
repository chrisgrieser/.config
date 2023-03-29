#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

query="$*!!" # "!!" makes searchlink just get the link
link="$(automator -r -i "$query" ~/Library/Services/SearchLink.workflow | sed -n 2p | cut -d\" -f2)"
echo -n "$link" | pbcopy
echo -n "$link" # for notification
