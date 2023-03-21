#!/usr/bin/env zsh

weather=$(curl "https://wttr.in/Berlin?format=1" | tr -d "C +" | sed 's/-0/0/')
if [[ "$weather" =~ Unknown ]] || [[ "$weather" =~ Sorry ]] || [[ -z "$weather" ]]; then
	icon=""
	temp="–"
else
	icon=$(echo "$weather" | cut -c1)
	temp=$(echo "$weather" | cut -c2-)
fi

# replace emoji weather fonts with nerd fonts does not seem to be working though :(
case "$icon" in
"✨") icon=" " ;;
"☁️") icon=" " ;;
"🌫") icon="敖" ;;
"🌧") icon=" " ;;
"❄️") icon=" " ;;
"🌦") icon=" " ;;
"🌨") icon=" " ;;
"⛅️") icon=" " ;;
"☀️") icon=" " ;;
"🌩") icon="朗" ;;
"⛈") icon=" " ;;
esac

sketchybar --set "$NAME" icon="$icon" label="$temp"
