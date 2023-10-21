#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

outdated=$(brew outdated --quiet | wc -l | tr -d " ")
threshold=30

# only show menubar item above threshold
if [[ $outdated -gt $threshold ]] ; then
	icon=" "
	label="$outdated"
else
	icon=""
	label=""
fi
sketchybar --set "$NAME" icon="$icon" label="$label"
