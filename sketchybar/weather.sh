#!/usr/bin/env zsh
#───────────────────────────────────────────────────────────────────────────────
# WEATHER USING BRIGHTSKY API
# API DOCS: https://brightsky.dev/docs/#get-/current_weather
#───────────────────────────────────────────────────────────────────────────────

# LOCATION
# INFO right-click on a location in Google Maps to get the latitude/longitude
# roughly Berlin-Tegel (no precise location due to pricacy)
readonly latitude=52
readonly longitude=13

export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
if ! command -v yq &>/dev/null; then
	temperature="yq not found"
	icon=""
	sketchybar --set "$NAME" icon="$icon" label="$temperature"
fi

#───────────────────────────────────────────────────────────────────────────────

# looping since sometimes the API returns no data or internet connection is not
# there yet on system startup
i=0
while true; do
	weather=$(curl -sL "https://api.brightsky.dev/current_weather?lat=$latitude&lon=$longitude" | yq ".weather")
	temperature="$(echo "$weather" | yq ".temperature" | cut -d. -f1)°"
	# replace icon-string with nerdfont icon
	icon=$(
		echo "$weather" | yq ".icon" |
			sed 's/partly-cloudy-day//' |
			sed 's/partly-cloudy-night//' |
			sed 's/rain//' |
			sed 's/cloudy//' |
			sed 's/wind//' |
			sed 's/fog/󰖑/' |
			sed 's/hail/󰖒/' |
			sed 's/snow//' |
			sed 's/clear-day//' |
			sed 's/clear-night//' |
			sed 's/thunderstorm//'
	)
	[[ -n "$icon" && "$icon" != "null" || $i -gt 20 ]] && break
	i=$((i + 1))
	sleep 5
done

#───────────────────────────────────────────────────────────────────────────────

if [[ "$temperature" == "null" ]] ; then
	icon=""
	temperature="–"
fi

sketchybar --set "$NAME" icon="$icon" label="$temperature"
