#!/usr/bin/env zsh
# shellcheck disable=2154 # alfred vars

if [[ ! -f "$HOME/.zshenv" && -z "$CHATPDF_API_KEY" ]]; then
	echo -n ".zshenv does not exist, and no ChatPDF API key has been provided. 
	One of the two is required for this workflow to work."
	return 1
elif [[ -z "$CHATPDF_API_KEY" ]]; then
	# shellcheck disable=1091
	source "$HOME/.zshenv" 
	api_key="$CHATPDF_API_KEY"
fi

file_path="$1"
the_prompt="Summarize the pdf in 10 bullet points. Ground your summary in the facts of the paper."

#───────────────────────────────────────────────────────────────────────────────
# chatpdf API request
# DOCS https://www.chatpdf.com/docs/api/backend

osascript -e 'display notification "" with title "🔼 Uploading pdf…"'

sourceId=$(curl -X POST "https://api.chatpdf.com/v1/sources/add-file" \
	-H "x-api-key: $api_key" \
	-F "file=@$file_path" |
	cut -d'"' -f4)

osascript -e 'display notification "" with title "🤖 Requesting Summary…"'

# INFO do not use `$prompt`, since it's a reserved zsh variable
content=$(curl -X POST "https://api.chatpdf.com/v1/chats/message" \
	-H "x-api-key: $api_key" \
	-H "Content-Type: application/json" \
	-d "{\"sourceId\": \"$sourceId\", \"messages\": [{\"role\": \"user\", \"content\": \"$the_prompt\"}]}" |
	cut -d'"' -f4)

#───────────────────────────────────────────────────────────────────────────────
# OUTPUT

if [[ "$save_as_file" == "1" ]]; then
	output_file="${file_path%.*}.md"
	echo "$content" > "$output_file"
elif [[ "$copy_to_clipboard" == "1" ]]; then
	echo -n "$content" | pbcopy
elif [[ "$alfred_large_type" == "1" ]]; then
	echo -n "$content"
fi
