#!/usr/bin/env zsh
# INFO this scripts basically replaces https://brettterpstra.com/projects/searchlink/
#───────────────────────────────────────────────────────────────────────────────

query="$1"
query_enc=$(osascript -l JavaScript -e "encodeURIComponent('$query')")
# SOURCE of the api call: https://github.com/ttscoff/searchlink/blob/e4e36d3173bc35fb5458908e3a64408350cb3583/lib/searchlink/searches/duckduckgo.rb#L97C98-L97C127
api_url="https://api.duckduckgo.com?kl=us-en&format=json&no_redirect=1&no_html=1&skip_disambig=1&q=$query_enc"
echo "searchlink URL: $api_url" >&2

# INFO `//` is like js' `||`, falling back to the next expression when `null`
first_url=$(curl --silent "$api_url" |
	jq --raw-output ".Results[0].FirstURL // .OfficialWebsite // .AbstractURL")

# what to send to Alfred
if [[ -z "$first_url" || "$first_url" == "null" ]]; then
	echo -n "$query" # will search for query, and then paste empty mdlink
else
	echo -n "[$query]($first_url)" # will paste
fi
