#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

[[ "$*" == "* root" ]] && folder="" || folder="$*/"
entry_name=$(echo "$entry_name" | tr -d ":/\\") # remove illegal characters

# shellcheck disable=2154
if [[ "$generatePassword" -eq 1 ]]; then
	pass generate --no-symbols "$folder$entry_name" &>/dev/null

	# pass to Alfred for copying
	echo -n "$(pass show "$folder$entry_name" | head -n1)"
else
	# echo needed to skip confirmation, not to pass password again
	pbpaste | pass insert --echo "$folder$entry_name" &>/dev/null
fi

# shellcheck disable=2154
[[ "$auto_push" == "1" ]] && pass git push &>/dev/null
