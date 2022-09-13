#!/usr/bin/env sh

weather=$(curl "https://wttr.in/Berlin?format=1" | tr -d "C ")
if [[ "$weather" =~ "Unknown" ]] ; then
	icon=""
	temp="–"
else
	icon=$(echo "$weather" | cut -d+ -f1)
	temp=$(echo "$weather" | cut -d+ -f2)
fi
sketchybar --set "$NAME" icon="$icon" label="$temp"
