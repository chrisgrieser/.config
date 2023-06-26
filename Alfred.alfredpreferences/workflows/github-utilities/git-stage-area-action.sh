#!/usr/bin/env zsh

# shellcheck disable=2154
file="$1"
cd "$repo" || return 1

if [[ "$staged" == "1" ]]; then
	git add "$file"
elif [[ "$wholeFile" == "0" ]]; then
	git restore --staged "$file"
elif [[ "$wholeFile" == "1" ]]; then
	git restore "$file"
fi

echo "$file"
