#!/usr/bin/env zsh

# shellcheck disable=2154
file="$todotxt_filepath"
new_text="$1"

#───────────────────────────────────────────────────────────────────────────────

sed -i '' "${line_no}c\
$new_text" "$file"
