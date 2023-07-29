#!/usr/bin/env zsh
# shellcheck disable=2154 # Alfred variables

# OPEN ANY URLS IN THE BUFFER
saved_urls="$alfred_workflow_cache/urlsToOpen.txt"
if [[ -f "$saved_urls" ]]; then
	sed '/^$/d' "$saved_urls" | xargs open
	rm "$saved_urls"
fi

#───────────────────────────────────────────────────────────────────────────────

# OPEN CURRENT URL
last_given_url="$*"
open "$last_given_url"

#───────────────────────────────────────────────────────────────────────────────

# LOG URLs

# log location left empty = user decided not to save logs
[[ ! -f "$log_location" ]] && return 0

# if query on search site, keep only the query part
queryOrUrl=$(echo "$last_given_url" | sed -E 's/.*q=(.*)/\1/') 
date_time_stamp=$(date +"%Y-%m-%d %H:%M")

# prepend to logfile
echo -e "$date_time_stamp – $queryOrUrl\n$(cat "$log_location")" > todo.txt

