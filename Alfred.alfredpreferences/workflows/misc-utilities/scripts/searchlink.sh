#!/usr/bin/env zsh
# INFO this scripts basically replaces https://brettterpstra.com/projects/searchlink/
#───────────────────────────────────────────────────────────────────────────────

query="$1"
query_enc=$(osascript -l JavaScript -e "encodeURIComponent('$query')")
ddgr_html_url="https://html.duckduckgo.com/html?kl=us-en&q=$query_enc"
echo "🪚 ddgr_html_url: $ddgr_html_url" >&2

first_result=$(
	curl --user-agent="searchlink" --silent "$ddgr_html_url" |
		grep --after-context=1 --max-count=1 "result__url" |
		tail -n1 |
		sed -E 's/^ *| *$//g'
)

if [[ -z "$first_result" ]]; then
	echo -n "No response from DuckDuckGo."
else
	echo -n "[$query](http://$first_result)" # paste via Alfred
fi
