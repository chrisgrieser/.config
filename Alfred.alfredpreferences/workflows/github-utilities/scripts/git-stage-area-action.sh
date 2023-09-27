#!/usr/bin/env zsh

file="$1"
# shellcheck disable=2154
cd "$repo" || return 1

# shellcheck disable=2154
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
