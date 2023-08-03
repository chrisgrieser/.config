#!/usr/bin/env zsh
# shellcheck disable=2154 # Alfred variables

# OPEN URL(S)
last_given_url="$*"
multi_select_buffer="$alfred_workflow_cache/multiSelectBuffer.txt"
if [[ -f "$multi_select_buffer" ]]; then
	urls="$(cat "$multi_select_buffer")\n$last_given_url"
	rm "$multi_select_buffer"
else
	urls="$last_given_url"
fi
echo "$urls" | xargs open

#───────────────────────────────────────────────────────────────────────────────
# LOG URLs

# log location left empty or non-existent = user decided not to save logs
[[ ! -f "$log_location" ]] && return 0


echo "$urls" | while read -r url; do
	# if query on search site, keep only the query part
	query_or_url=$(echo "$url" | sed -E 's/.*q=(.*)/\1/')

	# if query term and not an URL, decode the spaces
	[[ "$query_or_url" =~ "http" ]] || query_or_url=$(osascript -l JavaScript -e "decodeURIComponent('$query_or_url')")

	# prepend
	date_time_stamp=$(date +"%Y-%m-%d %H:%M")
	echo -e "$date_time_stamp – $query_or_url\n$(cat "$log_location")" >"$log_location"
done
