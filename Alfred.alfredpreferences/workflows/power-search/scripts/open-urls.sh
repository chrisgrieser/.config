#!/usr/bin/env zsh
# shellcheck disable=2154 # Alfred variables

# OPEN URL(S)
last_given_url="$*"
saved_urls="$alfred_workflow_cache/urlsToOpen.json"
if [[ -f "$saved_urls" ]]; then
	urls="$(cat "$saved_urls")\n$last_given_url"
	rm "$saved_urls"
else
	urls="$last_given_url"
fi
echo "$urls" | xargs open

#───────────────────────────────────────────────────────────────────────────────
# LOG URLs

# log location left empty or non-existent = user decided not to save logs
[[ ! -f "$log_location" ]] && return 0

date_time_stamp=$(date +"%Y-%m-%d %H:%M")

echo "$urls" | while read -r url; do
	# if query on search site, keep only the query part
	query_or_url=$(echo "$url" | sed -E 's/.*q=(.*)/\1/')

	# if query term and not an URL, decode the spaces
	[[ ! "$query_or_url" =~ "http" ]] && query_or_url=${query_or_url//%20/ /}

	# prepend
	echo -e "$date_time_stamp – $query_or_url\n$(cat "$log_location")" >"$log_location"
done
