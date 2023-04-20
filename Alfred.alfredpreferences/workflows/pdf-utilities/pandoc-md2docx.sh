#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

function md2docx () {
	cd "$(dirname "$1")" || return 1
	INPUT_FILE="$(basename "$*")"
	OUTPUT_FILE="${INPUT_FILE%.*}_CG.docx"

	pandoc \
		"$INPUT_FILE" \
		--output="$OUTPUT_FILE" \
		--data-dir="$DOTFILE_FOLDER/pandoc"\
		--defaults="md2docx" \
		--metadata=date:"$(date "+%d. %B %Y")" \
	&& open -R "$OUTPUT_FILE" \
	&& open "$OUTPUT_FILE"
}

# copy / pipe output, e.g. for information on missing citekeys
output=$(md2docx "$*" 2>&1)
echo "$output" | pbcopy
echo "$output"


