#!/usr/bin/env zsh

#───────────────────────────────────────────────────────────────────────────────
# INFO pandoc's --data-dir defined in .zshenv
#───────────────────────────────────────────────────────────────────────────────

if ! command -v wkhtmltopdf &>/dev/null; then echo "wkhtmltopdf not installed." && return 1; fi

INPUT="$*"
OUTPUT="${INPUT%.*}_CG.pdf"

ext=${INPUT##*.}
if [[ "$ext" != "md" ]]; then
	echo "⚠️ Selection not a Markdown file."
	return 1
fi

pandoc "$INPUT" --output="$OUTPUT" --defaults="md2pdf" 2>&1 &&
	open -R "$OUTPUT"
