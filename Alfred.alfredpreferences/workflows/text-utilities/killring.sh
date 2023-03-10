#!/usr/bin/env zsh
# shellcheck disable=2154
mkdir -p "${alfred_workflow_cache}"
readonly count_file="${alfred_workflow_cache}/counts_file"
readonly reset_mins='1'

# undo last paste
osascript -e 'tell application "System Events" to keystroke "z" using {command down}'

file_is_older_than_reset_time=$(find "$count_file" -mmin -"$reset_mins")
if [[ -n "$file_is_older_than_reset_time" ]]; then
	currentCount=$(cat "$count_file")
	n=$((currentCount + 1))
else
	[[ -f "$count_file" ]] && rm -f "$count_file"
	n=0
fi

echo -n "$n" >"$count_file"
echo -n "$n" # tell Alfred to paste the nth clipboard
