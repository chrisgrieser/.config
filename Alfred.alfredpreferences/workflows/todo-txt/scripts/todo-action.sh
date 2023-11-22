#!/usr/bin/env zsh

# shellcheck disable=2154
file="$todotxt_filepath"

action="$1"
line=$(sed -n "${line_no}p" "$file")

echo "$line" | grep -q "^x "
is_completed=$? # 0 if completed, 1 if not

#───────────────────────────────────────────────────────────────────────────────

if [[ "$action" == "open-url" ]]; then
	echo "$line" | grep -E --only-matching 'https?://[^ )]*' | xargs open
elif [[ "$action" == "copy" ]]; then
	echo -n "$line" | pbcopy
	echo -n "$line" # for Alfred notification
elif [[ "$action" == "toggle-completed" && "$is_completed" -eq 1 ]]; then
	# unmark as completed
	sed -E -i '' "${line_no}s/^x ([0-9]{4}-[0-9]{2}-[0-9]{2} )?//" "$file"
	return 0
fi

# complete (if not completed yet)
[[ "$is_completed" -eq 0 ]] ||
sed -E -i '' "${line_no}s/^/x $(date +%Y-%m-%d) /" "$file" # mark as completed if not
