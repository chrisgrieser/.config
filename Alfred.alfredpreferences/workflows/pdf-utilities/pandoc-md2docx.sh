#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

#───────────────────────────────────────────────────────────────────────────────
# INFO pandoc --data-dir defined in .zshenv
#───────────────────────────────────────────────────────────────────────────────

INPUT="$*"
OUTPUT="${INPUT%.*}_CG.docx"

stdout=$(pandoc "$INPUT" --output="$OUTPUT" --defaults="md2doc" 2>&1)
if [[ -z "$stdout" ]] ; then
	open "$OUTPUT"
	open -R "$OUTPUT"
else
	echo "$stdout"
fi
