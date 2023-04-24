#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

if ! command -v wkhtmltopdf &>/dev/null; then echo "wkhtmltopdf not installed." && return 1; fi

function md2pdf () {
	cd "$(dirname "$1")" || return 1
	INPUT_FILE="$(basename "$*")"
	OUTPUT_FILE="${INPUT_FILE%.*}_CG.pdf"

	pandoc \
		"$INPUT_FILE" \
		--output="$OUTPUT_FILE" \
		--data-dir="$DOTFILE_FOLDER/pandoc"\
		--defaults="md2pdf" \
	&& open -R "$OUTPUT_FILE" \
	&& open "$OUTPUT_FILE"
}

# copy / pipe output, e.g. for information on missing citekeys
output=$(md2pdf "$*" 2>&1)
# shellcheck disable=2181
if [[ $? -ne 0 ]] ; then
	echo "$output" | pbcopy
	echo "$output"
fi
