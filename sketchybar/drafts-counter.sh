#!/usr/bin/env zsh

scutil --get ComputerName | grep -iq "iMac"
IS_HOME=$?
if [[ $IS_HOME -eq 0 ]]; then
	exclude="office"
else
	exclude="home"
fi

cd "$(dirname "$0")" || exit 1 # python script in same folder as this script
count=$(python3 ./numberOfDrafts.py "tasklist" "$exclude" | xargs)

# only show menubar item if Drafts running and at least 1 task
if [[ $count -gt 0 ]] && pgrep -x "Drafts" ; then
	label="$count" 
	icon=""	
fi

sketchybar --set "$NAME" icon="$icon" label="$label"
