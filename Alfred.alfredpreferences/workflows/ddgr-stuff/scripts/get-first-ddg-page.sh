#!/usr/bin/env zsh
query=$(osascript -l JavaScript -e "encodeURIComponent('$1')")
echo "⭕ query: $query" >&2
first_url=$(curl --silent "https://html.duckduckgo.com/html?q=$query" |
	grep --after-context=1 --max-count=1 "result__url" |
	tail -n1)
	xargs open
