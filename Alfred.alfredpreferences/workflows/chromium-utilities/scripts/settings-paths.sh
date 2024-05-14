#!/usr/bin/env zsh
json=$(cat ./data/all-chromium-browser-settings.json)

# shellcheck disable=2154 # Alfred var
if [[ "$browser" == "Brave Browser" ]]; then
	json="$json$(cat ./data/brave-specific-settings.json)"
fi

echo "$json"
