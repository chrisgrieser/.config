#!/usr/bin/env zsh
#───────────────────────────────────────────────────────────────────────────────
# INFO pandoc's --data-dir defined in .zshenv
#───────────────────────────────────────────────────────────────────────────────

INPUT="$*"
OUTPUT="${INPUT%.*}_CG.pdf"

pandoc "$INPUT" --output="$OUTPUT" --defaults="md2pdf" 2>&1 &&
	open -R "$OUTPUT"
