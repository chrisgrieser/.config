#!/usr/bin/env zsh
#───────────────────────────────────────────────────────────────────────────────
# WEATHER USING BRIGHTSKY API
# DOCS: https://brightsky.dev/docs/#get-/current_weather
#───────────────────────────────────────────────────────────────────────────────

# LOCATION
# INFO right-click on a location in Google Maps to get the latitude/longitude
# roughly Berlin-Tegel (no precise location as this dotfile repo is public)
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
	temperature="$(echo "$weather" | yq ".temperature" | cut -d. -f1)"
	# replace icon-string with nerdfont icon
	icon=$(
		echo "$weather" | yq ".icon" |
			sed -e 's/partly-cloudy-day//' -e 's/partly-cloudy-night//' -e 's/rain//' \
				-e 's/cloudy//' -e 's/wind//' -e 's/fog/󰖑/' -e 's/hail/󰖒/' \
				-e 's/snow//' -e 's/clear-day//' -e 's/clear-night//' \
				-e 's/thunderstorm//'
	)
	[[ -n "$icon" && "$icon" != "null" || $i -gt 10 ]] && break
	i=$((i + 1))
	sleep 1.5
done

#───────────────────────────────────────────────────────────────────────────────

if [[ "$temperature" == "null" ]]; then
	icon=""
	temperature="–"
fi

sketchybar --set "$NAME" icon="$icon" label="$temperature°"
