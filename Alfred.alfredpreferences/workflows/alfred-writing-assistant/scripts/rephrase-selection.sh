#!/usr/bin/env zsh
# shellcheck disable=2154
#───────────────────────────────────────────────────────────────────────────────
# CALL OPENAI API via JXA, since it properly handles JSON without needing a dependency

selection="$*" # already checked via Alfred that selection is non-empty
cache="$alfred_workflow_cache"
mkdir -p "$cache"
rephrased=$(osascript -l JavaScript "./scripts/openai-request.js" "$selection")

# GUARD
[[ -z "$rephrased" ]] && rephrased="ERROR: Unknown error."
if [[ "$rephrased" =~ ^ERROR ]]; then
	echo "$rephrased"
	echo "$selection" # keep selection
	return 1
fi

#───────────────────────────────────────────────────────────────────────────────
# OUTPUT

if [[ "$output_type" == "plain" ]]; then
	echo "$rephrased"
	exit 0
fi

# MARKUP via git-diff
echo "$selection" > "$cache/selection.txt"
echo "$rephrased" > "$cache/rephrased.txt"

# INFO word regex works treats non-white-space characters as words, except for
# punctuation, which is considered individually. This makes diffs for natural
# language more readable, since a changed punctuation does not trigger the
# preceding word to be marked as well.
diff=$(git diff --word-diff-regex='[[:punct:]]|[^[[:space:]][[:punct:]]]+' \
	"$cache/selection.txt" "$cache/rephrased.txt" | sed -e "1,5d")

if [[ "$output_type" == "markdown" ]]; then
	output=$(echo "$diff" |
		sed -e 's/\[-/~~/g' -e 's/-\]/~~/g' -e 's/{+/==/g' -e 's/+}/==/g')
elif [[ "$output_type" == "critic-markup" ]]; then
	output=$(echo "$diff" |
		sed -e 's/\[-/{--/g' -e 's/-\]/--}/g' -e 's/{+/{++/g' -e 's/+}/++}/g')
fi

# ensure output has same amount of leading/trailing spaces
trailing_spaces=$(echo "$selection" | grep --only-matching --basic-regexp "\s*$")
leading_spaces=$(echo "$selection" | grep --only-matching --basic-regexp "^\s*")
output="$leading_spaces$output$trailing_spaces"
if [[ $(echo "$selection" | tail -n1) == "" ]]; then
	output="$output\n"
fi

# paste via Alfred
echo -n "$output"
