#!/usr/bin/env zsh
# shellcheck disable=1091

# https://www.chatpdf.com/docs/api/backend
#───────────────────────────────────────────────────────────────────────────────

source "$HOME/.zshrc" # source CHATPDF_API_KEY
file_path="$1"

response=$(curl -X POST "https://api.chatpdf.com/v1/sources/add-file" \
-H "x-api-key: $CHATPDF_API_KEY" \
-F "file=@$file_path")

id=$(echo "$response" | cut -d'"' -f4)
echo "$id" | pbcopy

open "https://www.chatpdf.com/c/$id"

