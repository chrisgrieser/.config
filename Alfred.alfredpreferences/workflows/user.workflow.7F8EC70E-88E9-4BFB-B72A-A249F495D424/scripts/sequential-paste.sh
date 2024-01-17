#!/usr/bin/env zsh
# shellcheck disable=2154
# https://www.alfredforum.com/topic/14534-sequential-paste-—-paste-previous-clipboard-entries-in-order%2f

readonly count_file="${alfred_workflow_cache}/sequentialpaste_counts_file.txt"
mkdir -p "${alfred_workflow_cache}"

reset_mins="2"

if [[ "$1" == 'reset' ]]; then
	rm "${count_file}"
	return 0
fi

if [[ ! -f "$count_file" || "$(find "${count_file}" -mmin +"${reset_mins}")" ]]; then
	count=1
else
	count=$(cat "$count_file")
	count=$((count + 1))
fi

echo "${count}" >"${count_file}"
echo -n "${count}"
