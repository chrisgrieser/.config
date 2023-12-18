#!/usr/bin/env zsh
# shellcheck disable=2154
mkdir -p "${alfred_workflow_cache}"
readonly count_file="${alfred_workflow_cache}/killring_counts_file.txt"
readonly reset_mins='1'

#───────────────────────────────────────────────────────────────────────────────

file_is_older_than_reset_time=$(find "$count_file" -mmin -"$reset_mins")
if [[ -n "$file_is_older_than_reset_time" ]]; then
	currentCount=$(cat "$count_file")
	count=$((currentCount + 1))
else
	[[ -f "$count_file" ]] && rm -f "$count_file"
	count=1 # start at first item in history
fi

#───────────────────────────────────────────────────────────────────────────────

echo -n "$count" >"$count_file"
echo -n "$count" # tells Alfred to paste this clipboard item
