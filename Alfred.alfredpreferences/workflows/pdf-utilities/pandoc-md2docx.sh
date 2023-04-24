#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

#───────────────────────────────────────────────────────────────────────────────
# INFO pandoc --data-dir defined in .zshenv
#───────────────────────────────────────────────────────────────────────────────

INPUT="$*"
OUTPUT="${INPUT%.*}_CG.docx"

stdout=$(pandoc "$*" --output="$OUTPUT" --defaults="md2docx" 2>&1)
if [[ $? -eq 0 ]] ; then
	open "$OUTPUT"
else
	echo "$stdout"
fi
