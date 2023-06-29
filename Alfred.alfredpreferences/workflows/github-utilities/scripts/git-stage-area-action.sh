#!/usr/bin/env zsh

# shellcheck disable=2154
file="$1"
cd "$repo" || return 1

if [[ "$mode" == "stage" ]]; then
	git add "$file"
elif [[ "$mode" == "unstage" ]]; then
	git restore --staged "$file"
elif [[ "$mode" == "reset" ]]; then
	git reset "$file"
elif [[ "$mode" == "reveal" ]]; then
	open -R "$file"
elif [[ "$mode" == "undo unstaged" ]]; then
	git restore "$file"
elif [[ "$mode" == "undo staged" ]]; then
	git reset HEAD "$file"
fi

echo "$file"
