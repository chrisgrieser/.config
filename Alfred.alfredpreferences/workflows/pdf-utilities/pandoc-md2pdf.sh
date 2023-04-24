#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

#───────────────────────────────────────────────────────────────────────────────
# INFO pandoc --data-dir defined in .zshenv
#───────────────────────────────────────────────────────────────────────────────

if ! command -v wkhtmltopdf &>/dev/null; then echo "wkhtmltopdf not installed." && return 1; fi

INPUT="$*"
OUTPUT="${INPUT%.*}_CG.pdf"

stdout=$(pandoc "$INPUT" --output="$OUTPUT" --defaults="md2pdf" 2>&1)
if [[ -z "$stdout" ]] ; then
	open "$OUTPUT"
	open -R "$OUTPUT"
else
	echo "$stdout"
fi
