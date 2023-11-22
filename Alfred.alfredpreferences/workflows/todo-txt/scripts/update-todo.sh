#!/usr/bin/env zsh

# shellcheck disable=2154
file="$todotxt_filepath"
new_text="$1"

#───────────────────────────────────────────────────────────────────────────────

sed "${line_no}c\\n$new_text" "$file"
