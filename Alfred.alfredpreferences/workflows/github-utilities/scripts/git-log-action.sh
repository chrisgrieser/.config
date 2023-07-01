#!/usr/bin/env zsh

# depending on mode, is either hash or branch, but both work with the same
# checkout command here

hashOrBranch="$*"
# shellcheck disable=2154
if [[ "$mode" == "Checkout" ]]; then
	git checkout "$hashOrBranch" 2>&1
elif [[ "$mode" == "Reset Hard" ]]; then
	git reset "$hashOrBranch" 2>&1
elif [[ "$mode" == "Copy Hash" ]]; then
	echo -n "$hashOrBranch" | pbcopy
	echo -n "$hashOrBranch" # for Alfred Notification
fi
