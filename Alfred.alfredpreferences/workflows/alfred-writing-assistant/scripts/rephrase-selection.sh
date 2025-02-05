#!/usr/bin/env zsh
# shellcheck disable=2154
#───────────────────────────────────────────────────────────────────────────────
# CALL OPENAI API via JXA, since it properly handles JSON without needing a dependency

selection="$*"
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
