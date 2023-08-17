#!/usr/bin/env zsh

#───────────────────────────────────────────────────────────────────────────────
# INFO pandoc's --data-dir defined in .zshenv
#───────────────────────────────────────────────────────────────────────────────

# guard clauses
if ! command -v wkhtmltopdf &>/dev/null; then echo "wkhtmltopdf not installed." && return 1; fi
if ! command -v pandoc &>/dev/null; then echo "pandoc not installed." && return 1; fi

INPUT="$*"
OUTPUT="${INPUT%.*}_CG.pdf"

ext=${INPUT##*.}
if [[ "$ext" != "md" ]]; then
	echo "⚠️ Selection not a Markdown file."
	return 1
fi

#───────────────────────────────────────────────────────────────────────────────
osascript -e 'display notification "" with title "⏳ Running pandoc…"'

pandoc "$INPUT" --output="$OUTPUT" --defaults="md2pdf" 2>&1 &&
	open -R "$OUTPUT"
