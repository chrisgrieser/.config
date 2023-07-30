#!/usr/bin/env zsh

today=$(date +%Y-%m-%d)

# `!` negates a sed match, q quits.
# -> Effectivlely, this reads the file until the *last* occurrence of $today

# shellcheck disable=2154 # alfred var
if [[ -f "$log_location" ]]; then
	sed "/$today/!q" "$log_location" | cut -d" " -f2-
else
	echo "No log file found at $log_location."
fi
