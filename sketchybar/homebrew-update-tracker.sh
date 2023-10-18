#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

outdated=$(brew outdated --quiet | wc -l | tr -d " ")
threshold=30

# only show menubar item above threshold
if [[ $outdated -gt $threshold ]] ; then
	sketchybar --set "$NAME" icon=" " label="$outdated"
else
	sketchybar --remove "$NAME"
fi
