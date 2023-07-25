#!/usr/bin/env zsh

# shellcheck disable=2154
file="$1"
cd "$repo" || return 1

if [[ "$mode" == "stage" ]]; then
	git add "$file"
elif [[ "$mode" == "unstage" ]]; then
	git restore --staged "$file"
elif [[ "$mode" == "discard" ]]; then
	git restore --staged "$file" # undo staging (does nothing if file is not staged)
	git restore "$file" # undo changes
elif [[ "$mode" == "reveal" ]]; then
	open -R "$file"
elif [[ "$mode" == "open" ]]; then
	open "$file"
fi

echo "$file"
