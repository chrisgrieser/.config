#!/usr/bin/env zsh
# INFO this scripts basically replaces https://brettterpstra.com/projects/searchlink/
#───────────────────────────────────────────────────────────────────────────────

query="$1"
query_enc=$(osascript -l JavaScript -e "encodeURIComponent('$query')")
region=${region:-"us-en"} # Alfred variable
ddgr_html_url="https://html.duckduckgo.com/html?q=$query_enc&kl=$region"

first_result=$(
	curl --silent "$ddgr_html_url" |
		grep --after-context=1 --max-count=1 "result__url" |
		tail -n1 |
		sed -E 's/^ *| *$//g'
)

first_result_url="http://$first_result"
mdlink="[$query]($first_result_url)"
echo -n "$mdlink" # paste via Alfred
