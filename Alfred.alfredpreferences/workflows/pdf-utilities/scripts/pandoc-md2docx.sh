#!/usr/bin/env zsh
#───────────────────────────────────────────────────────────────────────────────
# INFO pandoc's --data-dir defined in .zshenv
#───────────────────────────────────────────────────────────────────────────────

input="$(basename "$*" .md)"
date="$(date +%Y-%m-%d)"
output="${input}_${date}_CG.docx"

pandoc "$input" --output="$output" --defaults="md2docx" 2>&1 || return 1

open -R "$output"
open "$output"
