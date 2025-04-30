#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
#───────────────────────────────────────────────────────────────────────────────
# WEATHER USING BRIGHTSKY API
# DOCS: https://brightsky.dev/docs/#get-/current_weather
# alternative: https://open-meteo.com/
#───────────────────────────────────────────────────────────────────────────────

# CONFIG
# 1. right-click on a location in Google Maps to get the latitude/longitude
# 2. WARN only very vague location as this dotfile repo is public
readonly latitude=52
readonly longitude=13

#───────────────────────────────────────────────────────────────────────────────

# looping since sometimes the API returns no data or internet connection is not
# there yet on system startup
i=0
while true; do
	weather=$(curl -sL "https://api.brightsky.dev/current_weather?lat=$latitude&lon=$longitude" | jq ".weather")
	temperature="$(echo "$weather" | jq ".temperature" | cut -d. -f1 | sed 's/-0/0/')"
	# replace icon-string with nerdfont icon
	icon=$(
		echo "$weather" | jq ".icon" | sed \
			-e 's/partly-cloudy-day//' \
			-e 's/partly-cloudy-night//' \
			-e 's/rain//' \
			-e 's/cloudy//' \
			-e 's/wind//' \
			-e 's/fog/󰖑/' \
			-e 's/hail/󰖒/' \
			-e 's/snow//' \
			-e 's/clear-day//' \
			-e 's/clear-night//' \
			-e 's/thunderstorm//' \
			-e 's/sleet//'
	)
	[[ -n "$icon" || $i -gt 3 ]] && break
	i=$((i + 1))
	sleep 3
done

#───────────────────────────────────────────────────────────────────────────────

[[ "$temperature" == "null" ]] && temperature="–"
[[ "$icon" == "null" ]] && icon=""

sketchybar --set "$NAME" icon="$icon" label="$temperature°" drawing=true
