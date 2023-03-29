#!/usr/bin/env zsh
# shellcheck disable=2154
mkdir -p "${alfred_workflow_cache}"
readonly count_file="${alfred_workflow_cache}/counts_file"
readonly reset_mins='1'

#───────────────────────────────────────────────────────────────────────────────

osascript -e 'tell application "System Events" to keystroke "z" using {command down}' # undo last paste
file_is_older_than_reset_time=$(find "$count_file" -mmin -"$reset_mins")
if [[ -n "$file_is_older_than_reset_time" ]]; then
	currentCount=$(cat "$count_file")
	count=$((currentCount + 1))
else
	[[ -f "$count_file" ]] && rm -f "$count_file"
	count=0
fi

#───────────────────────────────────────────────────────────────────────────────

echo -n "$count" >"$count_file"
echo -n "$count" # tells Alfred to paste this clipboard item
