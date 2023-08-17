#!/usr/bin/env zsh
# DOCS https://www.chatpdf.com/docs/api/backend

#───────────────────────────────────────────────────────────────────────────────

# shellcheck disable=1091
source "$HOME/.zshenv" && api_key="$CHATPDF_API_KEY"
file_path="$1"
the_prompt="Summarize the pdf in 10 bullet points."

#───────────────────────────────────────────────────────────────────────────────

osascript -e 'display notification "" with title "🔼 Uploading pdf…"'

sourceId=$(curl -X POST "https://api.chatpdf.com/v1/sources/add-file" \
	-H "x-api-key: $api_key" \
	-F "file=@$file_path" |
	cut -d'"' -f4)

osascript -e 'display notification "" with title "🤖 Requesting Summary…"'

# INFO do not use `$prompt`, since it's a zsh builtin var
content=$(curl -X POST "https://api.chatpdf.com/v1/chats/message" \
	-H "x-api-key: $api_key" \
	-H "Content-Type: application/json" \
	-d "{\"sourceId\": \"$sourceId\", \"messages\": [{\"role\": \"user\", \"content\": \"$the_prompt\"}]}" |
	cut -d'"' -f4)

echo -n "$content" | pbcopy
echo -n "$content"
