#!/usr/bin/env zsh

scutil --get ComputerName | grep -iq "iMac"
IS_HOME=$?
if [[ $IS_HOME -eq 0 ]]; then
	list="office"
else
	list="home"
fi

cd "$(dirname "$0")" || exit 1 # python script in same folder as thing
count=$(python3 ./numberOfDrafts.py "tasklist" "$list" | xargs)
sketchybar --set "$NAME" icon="" label="$count"
