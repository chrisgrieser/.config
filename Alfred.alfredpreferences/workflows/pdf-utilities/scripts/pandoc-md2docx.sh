#!/usr/bin/env zsh
#───────────────────────────────────────────────────────────────────────────────
# INFO pandoc's --data-dir defined in .zshenv
#───────────────────────────────────────────────────────────────────────────────

input="$*"
input_no_ext=${input%\.md}
date="$(date +%Y-%m-%d)"
output="${input_no_ext}_${date}_CG.docx"

pandoc "$input" --output="$output" --defaults="md2docx" 2>&1 || return 1

open -R "$output"
open "$output"
