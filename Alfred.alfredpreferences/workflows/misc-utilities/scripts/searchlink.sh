#!/usr/bin/env zsh
# INFO this scripts basically replaces https://brettterpstra.com/projects/searchlink/
#───────────────────────────────────────────────────────────────────────────────

# SOURCE of the api call: https://github.com/ttscoff/searchlink/blob/e4e36d3173bc35fb5458908e3a64408350cb3583/lib/searchlink/searches/duckduckgo.rb#L97C98-L97C127
api_url="https://api.duckduckgo.com?kl=us-en&format=json&no_redirect=1&no_html=1&skip_disambig=1"
query="$1"

first_url=$(curl --get --url "$api_url" --data-urlencode "q=$query" |
	# INFO `//` is like js' `||`, falling back to the next expression when `null`
	jq --raw-output ".Results[0].FirstURL // .OfficialWebsite // .AbstractURL")

# what to send to Alfred
if [[ -z "$first_url" || "$first_url" == "null" ]]; then
	echo -n "$query" # will search for query, and then paste empty mdlink
else
	echo -n "[$query]($first_url)" # will paste
fi
