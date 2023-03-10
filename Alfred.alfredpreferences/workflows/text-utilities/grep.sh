#!/usr/bin/env zsh

# shellcheck disable=2154
result=$(echo "$toSearch" | grep --ignore-case "$*")

# paste via clipboard
echo -n "$result" | pbcopy
sleep 0.1
osascript -e 'tell application "System Events" to keystroke "v" using {command down}'

# shellcheck disable=2181
if [[ $? == 0 ]]; then
	echo "$result" | pbcopy
	echo -n "✅ copied;;$result"
else
	echo -n "🛑 '$*' not found"
fi
