#!/usr/bin/env zsh
# shellcheck disable=2154
file="$todotxt_filepath"
line_no=$1

#───────────────────────────────────────────────────────────────────────────────

if grep -q "^x " "$file"; then
	sed -i '' "${line_no}s/^x //" "$file"
else
	sed -i '' "${line_no}s/^/x /" "$file"
fi
