#!/usr/bin/env zsh

osascript -e 'display notification "" with title "weather update"'

weather=$(curl "https://wttr.in/Berlin?format=1" | tr -d "C ")
if [[ "$weather" =~ Unknown ]] || [[ "$weather" =~ Sorry ]]; then
	icon=""
	temp="–"
else
	icon=$(echo "$weather" | cut -c1)
	temp=$(echo "$weather" | cut -c3- | tr -d "+") # leave - temps, remove "+" from +temps
fi
sketchybar --set "$NAME" icon="$icon" label="$temp"
