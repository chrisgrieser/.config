#!/usr/bin/env zsh
# shellcheck disable=2154

# remove illegal characters
entry_name=$(echo "$*" | tr -d ":/\\")
entry="$folder/$entry_name"

# GUARD password file already exists
dir=${PASSWORD_STORE_DIR-$HOME/.password-store}
if [[ -f "$dir/$entry.gpg" ]]; then
	echo -n "ALREADY EXISTS"
	exit 1
fi

#───────────────────────────────────────────────────────────────────────────────

if [[ "$generatePassword" == "true" ]]; then
	pass generate "$entry" &> /dev/null

	# pass to Alfred for copying (not using `echo -n` due to #2)
	pass show "$entry" | head -n1

elif [[ "$generatePassword" == "false" ]]; then
	# create new password (`--echo` needed to skip confirmation)
	pbpaste | pass insert --echo "$entry" &> /dev/null

	# indicate to Alfred that password was inserted
	echo -n "INSERTED"
fi
