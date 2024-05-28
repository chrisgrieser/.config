#!/usr/bin/env zsh
# shellcheck disable=2154
#───────────────────────────────────────────────────────────────────────────────

# API KEY
apikey=$alfred_apikey
[[ -z "$apikey" ]] && apikey="$OPENAI_API_KEY" # defined in .zshenv

# GUARD
if [[ -z "$apikey" ]]; then
	echo "⚠️ No API key found."
	exit 1
fi

#───────────────────────────────────────────────────────────────────────────────
# CONSTRUCT PROMPT

selection="$*"
cache="$alfred_workflow_cache"
mkdir -p "$cache"

# `$prompt` is reserved variable in zsh, thus using `$the_prompt`
# also, escape quotes and line breaks in prompt for JSON
selection=${selection//
/\\\\n}
the_prompt=$(echo "$static_prompt $selection" | sed -e 's/"/\\"/g')

#───────────────────────────────────────────────────────────────────────────────

# OPENAI API CALL
# workaround, as oepnAI requires temp between 0 and 1, but ALfred's number
# slider only allows full integers
temp=$(echo "scale = 1; $temperature / 10" | bc)
[[ $temp -lt 1 ]] && temp="0$temp" # add leading zero required by OpenAI API

# DOCS https://platform.openai.com/docs/api-reference/making-requests
response=$(curl --silent --max-time 15 https://api.openai.com/v1/chat/completions \
	-H "Content-Type: application/json" \
	-H "Authorization: Bearer $apikey" \
	-d "{ \"model\": \"$openai_model\", \"messages\": [{\"role\": \"user\", \"content\": \"$the_prompt\"}], \"temperature\": $temp }")

# log the response to stderr (= visible in Alfred debug log, but not elsewhere)
echo "OpenAI response:" >&2
echo "$response" >&2

# GUARD
if [[ -z "$response" ]]; then
	echo "ERROR: Timeout, no response by OpenAI API."
	exit 1
elif [[ "$response" =~ '"error"' || "$response" =~ '"ERROR"' ]]; then
	error_msg=$(echo "$response" | grep '"message"' | cut -d'"' -f4)
	echo -n "ERROR: $error_msg"
	exit 1
fi

#───────────────────────────────────────────────────────────────────────────────
# GET THE CONTENT
# only with shell builtins to avoid jq dependency

if [[ $(echo "$response" | wc -l) -gt 1 ]]; then
	# unminified response -> multi-line
	text=$(
		echo "$response" |
			sed -n '/"content": /,/},/p' | sed '$d' |          # for multi-line responses
			sed -e 's/^[[:space:]]*"content": "//' -e 's/"$//' # get content-value
	)
else
	# minified response -> single line
	text=$(echo "$response" | grep --only-matching '"content":.*",' | cut -d'"' -f4)
fi

# unescape quotes
# shellcheck disable=2001
text="$(echo "$text" | sed -e 's/\\"/"/g')"

#───────────────────────────────────────────────────────────────────────────────

if [[ "$output_type" == "plain" ]]; then
	echo "$text"
	exit 0
fi

# MARKUP via git-diff
echo "$selection" >"$cache/selection.txt"
echo "$text" >"$cache/rephrased.txt"

# https://unix.stackexchange.com/questions/677764/show-differences-in-strings
diff=$(git diff --word-diff "$cache/selection.txt" "$cache/rephrased.txt" |
	sed -e "1,5d")

if [[ "$output_type" == "markdown" ]]; then
	output=$(echo "$diff" |
		sed -e 's/\[-/~~/g' -e 's/-\]/~~/g' -e 's/{+/==/g' -e 's/+}/==/g')
elif [[ "$output_type" == "critic-markup" ]]; then
	output=$(echo "$diff" |
		sed -e 's/\[-/{--/g' -e 's/-\]/--}/g' -e 's/{+/{++/g' -e 's/+}/++}/g')
fi

# ensure output has same amount of leading/trailing spaces
[[ "$selection" =~ \ $ ]] && output="$output "
[[ "$selection" =~ ^\  ]] && output=" $output"

# paste via Alfred
echo "$output"
