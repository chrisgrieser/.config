#!/usr/bin/env zsh

weather=$(curl -sL "https://wttr.in/Berlin?format=1")
temperature=$(echo "$weather" | cut -c2- | tr -d "+C ")

icon=$(
	echo "$weather" | cut -d" " -f1 |
		# replace emoji with nerdfont icons
		sed 's/🌧//' |
		sed 's/☁️//' |
		sed 's/🌫/敖/' |
		sed 's/🌧//' |
		sed 's/❄️//' |
		sed 's/🌦//' |
		sed 's/🌨//' |
		sed 's/⛅️//' |
		sed 's/☀️//' |
		sed 's/🌩/朗/' |
		sed 's/⛈//'
)

if [[ "$weather" =~ Unknown ]] || [[ "$weather" =~ Sorry ]] || [[ -z "$weather" ]]; then
	icon=""
	temperature="–"
fi

sketchybar --set "weather" icon="$icon" label="$temperature"
