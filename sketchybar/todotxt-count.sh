#!/usr/bin/env zsh

# INFO TODOTXT defined in .zshenv
todos=$(wc -l "$TODOTXT" | grep -E --only-matching --max-count=1 "\d+")
if [[ $todos -eq 0 ]] ; then
	todos=""
	icon=""
else
	icon=" "
fi
sketchybar --set "$NAME" label="$todos" icon="$icon" icon.padding_right=3
