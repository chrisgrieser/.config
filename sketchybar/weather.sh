#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
#───────────────────────────────────────────────────────────────────────────────
# WEATHER USING BRIGHTSKY API
# DOCS: https://brightsky.dev/docs/#get-/current_weather
#───────────────────────────────────────────────────────────────────────────────

# LOCATION
# INFO right-click on a location in Google Maps to get the latitude/longitude
# roughly Berlin-Tegel (no precise location as this dotfile repo is public)
readonly latitude=52
readonly longitude=13

if ! command -v yq &>/dev/null; then
	sketchybar --set "$NAME" icon="" label="yq not found"
	return 1
fi

#───────────────────────────────────────────────────────────────────────────────

# looping since sometimes the API returns no data or internet connection is not
# there yet on system startup
i=0
while true; do
	weather=$(curl -sL "https://api.brightsky.dev/current_weather?lat=$latitude&lon=$longitude" | yq ".weather")
	temperature="$(echo "$weather" | yq ".temperature" | cut -d. -f1)"
	# replace icon-string with nerdfont icon
	icon=$(
		echo "$weather" | yq ".icon" |
		sed -e 's/partly-cloudy-day//' -e 's/partly-cloudy-night//' \
			-e 's/rain//' -e 's/cloudy//' -e 's/wind//' -e 's/fog/󰖑/' \
			-e 's/hail/󰖒/' -e 's/snow//' -e 's/clear-day//' \
			-e 's/clear-night//' -e 's/thunderstorm//'
	)
	[[ -n "$icon" || $i -gt 5 ]] && break
	i=$((i + 1))
	sleep 3
done

#───────────────────────────────────────────────────────────────────────────────

[[ "$temperature" == "null" ]] && temperature="–"
[[ "$icon" == "null" ]] && icon=""

sketchybar --set "$NAME" icon="$icon" label="$temperature°"
