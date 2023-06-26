#!/usr/bin/env zsh

# shellcheck disable=2154
file="$1"
cd "$repo" || return 1

if [[ "$mode" == "new" ]]; then
	git add "$file"
elif [[ "$change" == "modified" ]]; then
	git restore --staged "$file"
elif [[ "$change" == "wholeFile" ]]; then
	git restore "$file"
fi

echo "$file"
