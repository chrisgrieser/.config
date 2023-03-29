#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

# https://www.thoughtasylum.com/alfred/alfred_slink_for_searchlink/
query="$*"
link="$(automator -r -i "$query" ~/Library/Services/SearchLink.workflow | sed -n 2p | cut -d\" -f2)"
echo -n "$link"
