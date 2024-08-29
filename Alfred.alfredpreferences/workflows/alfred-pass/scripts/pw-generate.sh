#!/usr/bin/env zsh
# shellcheck disable=2154

# remove illegal characters
entry_name=$(echo "$*" | tr -d ":/\\")

if [[ "$generatePassword" == "true" ]]; then
	pass generate "$folder/$entry_name" &>/dev/null

	# pass to Alfred for copying (not using `echo -n` due to #2)
	pass show "$folder/$entry_name" | head -n1

elif [[ "$generatePassword" == "false" ]]; then
	# create new password (`--echo` needed to skip confirmation)
	pbpaste | pass insert --echo "$folder/$entry_name" &>/dev/null

	# indicate to Alfred that password was inserted
	echo ""
fi

# shellcheck disable=2154
[[ "$auto_push" == "1" ]] && pass git push &>/dev/null
