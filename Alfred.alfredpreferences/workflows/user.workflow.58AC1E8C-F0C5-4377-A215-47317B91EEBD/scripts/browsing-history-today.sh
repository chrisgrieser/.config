#!/usr/bin/env zsh

today=$(date +%Y-%m-%d)

# `!` negates a sed match, q quits.
# -> Effectivlely, this reads the file until the first occurrence of a line that
# is not $today

# shellcheck disable=2154 # alfred var
if [[ -f "$log_location" ]]; then
	sed "/$today/!q" "$log_location" | # read until it's not today
		sed '$d' |                        # remove last line
		cut -d" " -f2-                    # remove date
else
	echo "No log file found at $log_location."
fi
