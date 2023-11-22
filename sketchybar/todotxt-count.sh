#!/usr/bin/env zsh

# INFO TODOTXT defined in .zshenv
not_empty_or_completed=$(grep -Ecv "^$|^x " "$TODOTXT")
if [[ $not_empty_or_completed -eq 0 ]] ; then
	todos=""
	icon=""
else
	todos="$not_empty_or_completed"
	icon=" "
fi
sketchybar --set "$NAME" label="$todos" icon="$icon" icon.padding_right=3
