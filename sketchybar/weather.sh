#!/usr/bin/env bash

weather=$(curl -sL "https://wttr.in/Berlin?format=1")
icon=$(echo "$weather" | cut -d" " -f1)
temperature=$(echo "$weather" | cut -c2- | tr -d "+C ")

# helper to replace the weather icons with their nerdfont equivalents, since
# replacing them via `sed` does not seem to work
# icon=$(osascript -l JavaScript ./weather-emoji-to-nerdfont.js "$icon")

icon=$(echo -n "$icon" | sed 's/🌧//')

if [[ "$weather" =~ Unknown ]] || [[ "$weather" =~ Sorry ]] || [[ -z "$weather" ]]; then
	icon=""
	temperature="–"
fi

sketchybar --set "weather" icon="$icon" label="$temperature" 
