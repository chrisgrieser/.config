#!/usr/bin/env zsh
# shellcheck disable=2154
mkdir -p "${alfred_workflow_cache}"
readonly count_file="${alfred_workflow_cache}/counts_file"
readonly reset_mins='1'

# if count file does not exist anymore, or after one minute
if [[ "$(find "$count_file" -mmin +"$reset_mins")" ]]; then
	[[ -f "$count_file" ]] && rm -f "$count_file"
	currentCount=$(cat "$count_file" | xargs)
	count=$((currentCount + 1))
else
	count=0
fi

echo "$count" >"$count_file"
echo -n "$count"
