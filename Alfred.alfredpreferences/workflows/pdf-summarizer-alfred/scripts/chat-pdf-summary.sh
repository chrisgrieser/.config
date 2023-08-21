#!/usr/bin/env zsh
# shellcheck disable=2154 # alfred vars
#───────────────────────────────────────────────────────────────────────────────

# GUARDS
file_path="$1"
if [[ ! -f "$file_path" ]]; then
	echo "No file selected."
	return 1
elif [[ $# -gt 1 ]]; then
	echo "Only one file can be processed at a time."
	return 1
elif [[ ! "$file_path" =~ \.pdf$ ]]; then
	echo "Selected file not a PDF."
	return 1
fi

if [[ "$CHATPDF_API_KEY" == ".zshenv" ]]; then
	# shellcheck disable=1091
	source "$HOME/.zshenv"
	if [[ -z "$CHATPDF_API_KEY" ]]; then
		echo -n "There is no ChatPDF API key in the .zshenv"
		return 1
	fi
fi

#───────────────────────────────────────────────────────────────────────────────
# chatpdf API request
# DOCS https://www.chatpdf.com/docs/api/backend

osascript -e 'display notification "" with title "🔼 Uploading pdf…"'

sourceId=$(curl -X POST "https://api.chatpdf.com/v1/sources/add-file" \
	-H "x-api-key: $CHATPDF_API_KEY" \
	-F "file=@$file_path" |
	cut -d'"' -f4)

osascript -e 'display notification "" with title "🤖 Requesting Summary…"'

# make prompt safe for JSON
the_prompt="$(echo -n "$the_prompt" | tr -d '\n' | sed 's/"/\\"/g')"

# INFO do not use `$prompt`, since it's a reserved zsh variable
content=$(curl -X POST "https://api.chatpdf.com/v1/chats/message" \
	-H "x-api-key: $CHATPDF_API_KEY" \
	-H "Content-Type: application/json" \
	-d "{\"sourceId\": \"$sourceId\", \"messages\": [{\"role\": \"user\", \"content\": \"$the_prompt\"}]}" |
	cut -d'"' -f4)

#───────────────────────────────────────────────────────────────────────────────
# OUTPUT

if [[ "$save_as_file" == "1" ]]; then
	output_file="${file_path%.*}.md"
	echo "$content" >"$output_file"
	open -R "$output_file"
fi

if [[ "$copy_to_clipboard" == "1" ]]; then
	echo -n "$content" | pbcopy
	# if *only* clipboard is used as output method, there is no implicit indication
	# that we are done, so we should send a notification
	if [[ "$alfred_large_type" != "1" && "$save_as_file" != "1" ]]; then
		osascript -e 'display notification "" with title "📋 Copied to clipboard."'
	fi
fi

if [[ "$alfred_large_type" == "1" ]]; then
	echo -n "$content"
fi
