#!/usr/bin/env zsh

# CONFIG
_export_github_token

#───────────────────────────────────────────────────────────────────────────────

# GUARD not when on projector
if [[ $(system_profiler SPDisplaysDataType | grep -c Resolution) -gt 1 ]]; then
	sketchybar --set "$NAME" drawing=false
	return 0
elif [[ -z "$GITHUB_TOKEN" ]]; then
	sketchybar --set "$NAME" label="NO TOKEN" drawing=true
	return 1
fi

# in office, spotty internet on wake
[[ "$SENDER" == "system_woke"]] && sleep 10
osascript -e "display notification \"🪚 $SENDER\" with title \"SENDER\""

#───────────────────────────────────────────────────────────────────────────────


# DOCS https://docs.github.com/en/rest/activity/notifications?apiVersion=2022-11-28
response=$(curl --silent --location \
	-H "Accept: application/vnd.github+json" \
	-H "Authorization: Bearer $GITHUB_TOKEN" \
	-H "X-GitHub-Api-Version: 2022-11-28" \
	"https://api.github.com/notifications")

if [[ -z "$response" ]]; then
	sketchybar --set "$NAME" label="󰣼" drawing=true
	return 1
fi
error=$(echo "$response" | jq --raw-output ".message")
if [[ -n "$error" ]]; then
	sketchybar --set "$NAME" label=" $error" drawing=true
	return 1
fi

notification_count=$(echo "$response" | jq ". | length")
if [[ $notification_count -eq 0 ]]; then
	sketchybar --set "$NAME" drawing=false
else
	sketchybar --set "$NAME" drawing=true label="$notification_count"
fi
