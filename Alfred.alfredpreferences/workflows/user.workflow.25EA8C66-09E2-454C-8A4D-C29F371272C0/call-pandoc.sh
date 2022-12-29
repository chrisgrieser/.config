#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

function md2docx () {
	cd "$(dirname "$*")" || return
	INPUT_FILE="$(basename "$*")"
	OUTPUT_FILE="${INPUT_FILE%.*}_CG.docx"

	pandoc \
		"$INPUT_FILE" \
		--output="$OUTPUT_FILE" \
		--defaults=Paper-Word \
		--metadata=date:"$(date "+%d. %B %Y")" \
	&& open -R "$OUTPUT_FILE" \
	&& open "$OUTPUT_FILE"
}


output=$(md2docx "$*" 2>&1)
echo "$output" | pbcopy
echo "$output"

# function docx2md () {
# 	cd "$(dirname "$*")" || return
# 	INPUT_FILE="$(basename "$*")"
# 	OUTPUT_FILE="${INPUT_FILE%.*}_imported.md"
#
# 	pandoc \
# 		"$INPUT_FILE" \
# 		--output="$OUTPUT_FILE" \
# 		--defaults=docx2md
#
# 	mv ./attachments/media/* ./attachments/
# 	rmdir ./attachments/media/
# 	sed -i '' 's/\/media\//\//g' "$OUTPUT_FILE"
# 	sed -i '' 's/„/"/' "$OUTPUT_FILE"
#
# 	open -R "$OUTPUT_FILE"
# }

