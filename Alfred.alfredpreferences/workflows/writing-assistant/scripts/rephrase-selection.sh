#!/usr/bin/env zsh
# shellcheck disable=2154
#───────────────────────────────────────────────────────────────────────────────

selection="$*"
the_prompt="$static_prompt$selection" # WARN `$prompt` is reserved variable in zsh
cache="$alfred_workflow_cache"
mkdir -p "$cache"
model="gpt-3.5-turbo" # https://platform.openai.com/docs/models/gpt-3

# use Alfred definition of API key, or use the OPENAI_API_KEY
# environment variable from .zshenv
apikey=$alfred_apikey
[[ -z "$apikey" ]] && apikey="$OPENAI_API_KEY" # defined in .zshenv

# GUARD
if [[ -z "$apikey" ]]; then
	echo "⚠️ No API key found."
	echo "$selection"
	return 1
fi

# OPENAI API CALL
# DOCS https://platform.openai.com/docs/api-reference/making-requests
response=$(curl --silent https://api.openai.com/v1/chat/completions \
	-H "Content-Type: application/json" \
	-H "Authorization: Bearer $apikey" \
	-d "{ \"model\": \"$model\", \"messages\": [{\"role\": \"user\", \"content\": \"$the_prompt\"}], \"temperature\": $temperature }" |
	grep '"content"' | cut -d'"' -f4) # doing this avoids jq dependency

#───────────────────────────────────────────────────────────────────────────────

if [[ "$output_flavor" == "response" ]]; then
	echo -n "$response"
	exit 0
fi

echo "$selection" >"$cache/selection.txt"
echo "$response" >"$cache/rephrased.txt"

# https://unix.stackexchange.com/questions/677764/show-differences-in-strings
diff=$(git diff --word-diff "$cache/selection.txt" "$cache/rephrased.txt" |
	sed -e "1,5d")

if [[ "$output_flavor" == "markdown" ]]; then
	output=$(echo "$diff" |
	sed -e 's/\[-/~~/g' -e 's/-\]/~~/g' -e 's/{+/==/g' -e 's/+}/==/g')
elif [[ "$output_flavor" == "critic-markup" ]]; then
	output=$(echo "$diff" |
	sed -e 's/\[-/{--/g' -e 's/-\]/--}/g' -e 's/{+/{++/g' -e 's/+}/++}/g')
fi

# paste via Alfred
echo -n "$output"
