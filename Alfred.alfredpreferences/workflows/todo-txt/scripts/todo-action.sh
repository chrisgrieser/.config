#!/usr/bin/env zsh

# shellcheck disable=2154
file="$todotxt_filepath"
action="$1"
line=$(sed -n "${lineNo}p" "$file")
state=$(echo "$line" | grep -q "^x " && echo "completed" || echo "open")

#───────────────────────────────────────────────────────────────────────────────

if [[ "$action" == "open-url" ]]; then
	echo "$line" | grep -E --only-matching 'https?://[^ )]*' | xargs open
elif [[ "$action" == "copy" ]]; then
	echo -n "$line" | pbcopy
	echo -n "$line" # for Alfred notification
elif [[ "$action" == "toggle-completed" && "$state" == "completed" ]]; then
	# unmark as completed
	sed -E -i '' "${lineNo}s/^x ([0-9]{4}-[0-9]{2}-[0-9]{2} )?//" "$file"
fi

# complete (if not completed yet)
[[ "$state" == "open" ]] &&
	sed -E -i '' "${lineNo}s/^/x $(date +%Y-%m-%d) /" "$file" # mark as completed if not

# loop back
[[ "$action" == "toggle-completed" ]] && 
	osascript -e 'tell application id "com.runningwithcrayons.Alfred" to run trigger "loop" in workflow "com.grieser.todotxt"'
