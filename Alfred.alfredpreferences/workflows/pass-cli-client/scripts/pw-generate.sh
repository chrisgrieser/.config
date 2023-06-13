#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

# lowercase & kebab-case
entry_name=${*/ /-}
entry_name=${entry_name:l}

folder=${folder:1} # cut "*" which marked entry as folder

msg=$(pass generate --clip --no-symbols "$folder/$entry_name" "${password_length:?}" 2>&1)

# shellcheck disable=2181
if [[ "$?" -eq 0 ]]; then
	echo "$msg"	| tail -n1
else
	echo "$msg"
fi
