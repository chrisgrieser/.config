#!/usr/bin/env zsh
# USING BRIGHTSKY API
# API DOCS: https://brightsky.dev/docs/#get-/current_weather
#───────────────────────────────────────────────────────────────────────────────

# LOCATION
# INFO right-click on a location in Google Maps to get the latitude/longitude
# entering rounded values suffices (privacy)

# location: roughly Berlin-Tegel
readonly latitude=52
readonly longitude=13

#───────────────────────────────────────────────────────────────────────────────

# add potential yq locations to path (homebrew or mason)
export PATH="$HOME/.local/share/nvim/mason/bin":/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

if ! command -v yq &>/dev/null; then
	weather="yq"
	icon=""
else
	weather=$(curl -sL "https://api.brightsky.dev/current_weather?lat=$latitude&lon=$longitude" | yq ".weather")
	temperature=$(echo "$weather" | yq ".temperature" | cut -d. -f1)
	# replace icon-string with nerdfont icon
	icon=$(
		echo "$weather" | yq ".icon" |
			sed 's/rain//' |
			sed 's/cloudy//' |
			sed 's/wind//' |
			sed 's/fog/󰖑/' |
			sed 's/hail/󰖒/' |
			sed 's/snow//' |
			sed 's/partly-cloudy-day//' |
			sed 's/partly-cloudy-night//' |
			sed 's/clear-day//' |
			sed 's/clear-night//' |
			sed 's/thunderstorm//'
	)
fi

sketchybar --set "$NAME" icon="$icon" label="$temperature"
