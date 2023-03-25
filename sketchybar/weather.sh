#!/usr/bin/env zsh

weather=$(curl "https://wttr.in/Berlin?format=1")
if [[ "$weather" =~ Unknown ]] || [[ "$weather" =~ Sorry ]] || [[ -z "$weather" ]]; then
	icon=""
	temperature="–"
else
	icon=$(echo "$weather" | cut -d" " -f1)
	temperature=$(echo "$weather" | cut -c2- | tr -d "+C ")
	# helper to replace the weather icons with their nerdfont equivalents, since
	# replacing them via `sed` does not seem to work
	icon=$(osascript -l JavaScript ./weather-emoji-to-nerdfont.js "$icon" | sed 's/^\s*//' | sed 's/\s*$//')
fi

sketchybar --set "$NAME" icon="$icon" label="$temperature"
