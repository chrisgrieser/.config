#!/usr/bin/env zsh

#───────────────────────────────────────────────────────────────────────────────
# INFO pandoc's --data-dir defined in .zshenv
#───────────────────────────────────────────────────────────────────────────────

INPUT="$*"
OUTPUT="${INPUT%.*}_CG.docx"

pandoc "$INPUT" --output="$OUTPUT" --defaults="md2docx" 2>&1 &&
	open -R "$OUTPUT"
