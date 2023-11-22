#!/usr/bin/env zsh

# shellcheck disable=2154
file="$todotxt_filepath"
line_no=$1

#───────────────────────────────────────────────────────────────────────────────

# open url
sed -n "${line_no}p" "$file" | pbcopy

# complete
sed -n "${line_no}p" "$file" |                              # get line
	grep -q "^x " ||                                           # check if completed
	sed -E -i '' "${line_no}s/^/x $(date +%Y-%m-%d) /" "$file" # mark as completed if not
