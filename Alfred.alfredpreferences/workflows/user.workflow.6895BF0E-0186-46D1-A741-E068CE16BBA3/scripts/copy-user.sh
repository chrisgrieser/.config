#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

user=$(pass show "$*" | grep -i "user:")

if [[ -z "$user" ]]; then
	echo "No user set for this entry."
	exit 1
fi

user=$(echo "$user" | cut -d: -f2)

echo "$user" | pbcopy
echo "Copied user: $user" # for notification
