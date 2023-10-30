#!/usr/bin/env zsh
# shellcheck disable=2154

selection="$*"
the_prompt="$static_prompt$selection" # WARN `$prompt` is a reserved variable name for zsh

# use Alfred definition of API key, or use the OPENAI_API_KEY
# environment variable from .zshenv
apikey=$alfred_apikey
[[ -z "$apikey" ]] && apikey="$OPENAI_API_KEY" # defined in .zshenv

#───────────────────────────────────────────────────────────────────────────────
# THE CALL
# DOCS https://platform.openai.com/docs/api-reference/making-requests
response=$(curl https://api.openai.com/v1/chat/completions \
	-H "Content-Type: application/json" \
	-H "Authorization: Bearer $apikey" \
	-d "{ \"model\": \"$model\", \"messages\": [{\"role\": \"user\", \"content\": \"$the_prompt\"}], \"temperature\": $temperature }" |
	grep '"content"' | cut -d'"' -f4)

echo "$selection" > "$alfred_workflow_cache/selection.txt"
echo "$response" > "$alfred_workflow_cache/selection.txt"

git diff --word-diff --color one two | 
	sed -e "1,5d" -e "s/\[-//g" -e $'s/-\]/\033[1;34m>/g' -e "s/+}//g" -e "s/{+//g" | 
	ansifilter --rtf --font-size=30 > out.rtf 

qlmanage -p out.rtf
