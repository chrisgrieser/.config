#!/usr/bin/env zsh

weather=$(curl "https://wttr.in/Berlin?format=1" | tr -d "C +" | sed 's/-0/0/')
if [[ "$weather" =~ Unknown ]] || [[ "$weather" =~ Sorry ]] || [[ -z "$weather" ]]; then
	icon=""
	temperature="–"
else
	icon=$(echo "$weather" | cut -c1)
	temperature=$(echo "$weather" | cut -c2-)
fi

sketchybar --set "$NAME" icon="$icon" label="$temperature"
