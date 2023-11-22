#!/usr/bin/env zsh
# shellcheck disable=2154

new_text="$*"

sed -i '' "${lineNo}c\\
$new_text
" "$todotxt_filepath"
