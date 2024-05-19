#!/usr/bin/env zsh
# INFO simple ddgr replacement when only the first URL is needed
#───────────────────────────────────────────────────────────────────────────────

query=$(osascript -l JavaScript -e "encodeURIComponent('$1')")
region=${region:-"us-en"} # Alfred variable, defaults to `us-en`
ddgr_html_url="https://html.duckduckgo.com/html?q=$query&kl=$region"

first_result=$(
	curl --silent "$ddgr_html_url" |
		grep --after-context=1 --max-count=1 "result__url" |
		tail -n1 |
		sed -E 's/^ *| *$//g'
)
first_result_url="http://$first_result"

echo -n "$first_result_url" | pbcopy
echo -n "$first_result_url" # Alfred notitication
