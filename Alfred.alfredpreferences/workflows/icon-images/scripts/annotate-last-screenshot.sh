#!/usr/bin/env zsh

# shellcheck disable=SC2154 # Alfred variable
loc="$screenshot_folder"

# shellcheck disable=SC2012 # special charrs not to be expected here
last_screenshot=$(ls -t "$loc" | head -n1)
if [[ -z "$last_screenshot" ]]; then
	echo "⚠️ No screenshots found."
else
	open "$loc/$last_screenshot"
fi
