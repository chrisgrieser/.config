#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
if ! command -v wkhtmltopdf &>/dev/null; then echo "wkhtmltopdf not installed." && return 1; fi

#───────────────────────────────────────────────────────────────────────────────
# INFO pandoc --data-dir defined in .zshenv
#───────────────────────────────────────────────────────────────────────────────

INPUT="$*"
OUTPUT="${INPUT%.*}_CG.pdf"

pandoc "$*" --output="$OUTPUT" --defaults="md2pdf" 1>/dev/null && open "$OUTPUT"
