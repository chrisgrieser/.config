#!/usr/bin/env zsh
# shellcheck disable=2154
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

if [[ "$generate_pw" ]]; then
	
fi
# new password from clipboard
pbpaste | pass insert --echo "$folder/$entry_name" &>/dev/null

echo -n "Password saved for $entry_name"
