#!/usr/bin/env zsh

# shellcheck disable=2154
file="$1"
cd "$repo" || return 1

if [[ "$doStage" == "1" ]]; then
	git add "$file"
elif [[ "$actOnWholeFile" == "0" ]]; then
	git restore --staged "$file"
elif [[ "$actOnWholeFile" == "1" ]]; then
	git restore "$file"
fi

echo "$file"
