#!/usr/bin/env zsh
# INFO simple ddgr replacement when only the first URL is needed
#───────────────────────────────────────────────────────────────────────────────

query=$(osascript -l JavaScript -e "encodeURIComponent('$1')")
region=${region:-"us-en"} # Alfred variable
ddgr_html_url="https://html.duckduckgo.com/html?q=$query&kl=$region"

first_result=$(
	curl --silent "$ddgr_html_url" |
		grep --after-context=1 --max-count=1 "result__url" |
		tail -n1 |
		sed -E 's/^ *| *$//g'
)
echo -n "http://$first_result"
