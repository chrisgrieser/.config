#!/usr/bin/env zsh

# INFO TODOTXT defined in .zshenv
non_empty_lines=$(grep -cv "^$" "$TODOTXT")
if [[ $non_empty_lines -eq 0 ]] ; then
	todos=""
	icon=""
else
	todos="$non_empty_lines"
	icon=" "
fi
sketchybar --set "$NAME" label="$todos" icon="$icon" icon.padding_right=3
