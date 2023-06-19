#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

[[ "$*" == "* root" ]] && folder="" || folder="$*/"
entry_name=$(echo "$entry_name" | tr -d ":/\\") # remove illegal characters

# shellcheck disable=2154
if [[ "$generatePassword" -eq 1 ]]; then
	pass generate --clip --no-symbols "$folder$entry_name" "${password_length:?}" 2>&1
else
	pbpaste | pass insert --echo "$folder$entry_name" 2>&1
fi
