#!/usr/bin/env zsh

if scutil --get ComputerName | grep -iq "iMac"; then
	exclude="office"
else
	exclude="home"
fi

cd "$(dirname "$0")" || exit 1 # python script in same folder as this script
count=$(python3 ./numberOfDrafts.py "tasklist" "$exclude" | xargs)

# only show menubar item if at least 1 task
if [[ $count -gt 0 ]] ; then
	label="$count" 
	icon=""	
fi

sketchybar --set "$NAME" icon="$icon" label="$label"
