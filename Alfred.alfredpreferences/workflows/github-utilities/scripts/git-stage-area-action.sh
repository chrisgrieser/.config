#!/usr/bin/env zsh

# shellcheck disable=2154
file="$1"
cd "$repo" || return 1

if [[ "$mode" == "stage" ]]; then
	git add "$file"
elif [[ "$mode" == "reveal" ]]; then
	open -R "$file"
elif [[ "$mode" == "undo unstaged" ]]; then
	git restore "$file"
elif [[ "$mode" == "undo staged" ]]; then
	git reset HEAD "$file"
elif [[ "$mode" == "unstage file" ]]; then
	git restore --staged "$file"
elif [[ "$mode" == "unstage change" ]]; then
	git restore "$file"
fi

echo "$file"
