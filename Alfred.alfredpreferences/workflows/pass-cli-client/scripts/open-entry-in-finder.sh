#!/usr/bin/env zsh

pass_path="$PASSWORD_STORE_DIR"
[[ -z "$pass_path" ]] && pass_path="$HOME/.password-store"
entry=$(echo "$*" | tr -d '*') # remove the "*" marking entry as folder

gpg="$pass_path/$entry.gpg"
folder="$pass_path/$entry"

if [[ -d "$folder" ]]; then
	open "$folder"
elif [[ -f "$gpg" ]]; then
	open -R "$gpg"
fi
