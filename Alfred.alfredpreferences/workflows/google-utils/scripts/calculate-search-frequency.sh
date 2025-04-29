#!/usr/bin/env zsh

# LOG RESULT
isodate=$(date +%Y-%m-%d)
isotime=$(date +%H:%M:%S)
query="$1"

# shellcheck disable=2154 # Alfred env var
echo "$isotime – $query" >> "$search_log_folder/$isodate.log"

#───────────────────────────────────────────────────────────────────────────────

# DISPLAY COUNT (10% of the time)

# abort 90% of the time -> only display the notification 10% of the time
if ((RANDOM % 100 > 90)); then return 0; fi

# count searches in the last 30 days
current_days=$(find "$search_log_folder" -type f -name "*.log" -mtime -30d | wc -l | tr -d " ")
searches_in_last_30d=$(find "$search_log_folder" -type f -name "*.log" -mtime -30d -print0 |
	xargs -0 wc -l |                                  # count lines
	tail -n1 |                                        # only total
	grep --only-matching --extended-regexp "^\s*\d+") # only the number

# DOCS https://kagi.com/pricing
echo "$searches_in_last_30d searches (Kagi: 300/month)" # Alfred notification
echo "($current_days days)"
