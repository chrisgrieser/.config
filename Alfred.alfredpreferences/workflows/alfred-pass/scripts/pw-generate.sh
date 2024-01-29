#!/usr/bin/env zsh

entry_name=$(echo "$*" | tr -d ":/\\") # remove illegal characters

# shellcheck disable=2154
if [[ "$generatePassword" == "true" ]]; then
	pass generate --no-symbols "$folder/$entry_name" &>/dev/null

	# pass to Alfred for copying
	echo -n "$(pass show "$folder/$entry_name" | head -n1)"
else
	# echo needed to skip confirmation, so not to pass password again
	pbpaste | pass insert --echo "$folder/$entry_name" &>/dev/null
	open -R "$folder/$entry_name" # show folder as form of confirmation
fi

# shellcheck disable=2154
[[ "$auto_push" == "1" ]] && pass git push &>/dev/null
