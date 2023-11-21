#!/usr/bin/env zsh

# shellcheck disable=2154
file="$todotxt_filepath"
line_no=$1

#───────────────────────────────────────────────────────────────────────────────

# open url
line=$(sed -n "${line_no}p" "$file")
url=$(echo "$line" | grep -E --only-matching 'https?://[^ )]*')
open "$url"

# if task is not completed, mark is as completed
grep -q "^x " "$file" ||
	sed -E -i '' "${line_no}s/^/x $(date +%Y-%m-%d) /" "$file"
