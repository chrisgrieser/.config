#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
#───────────────────────────────────────────────────────────────────────────────

# GUARD not when on projector
if [[ $(system_profiler SPDisplaysDataType | grep -c Resolution) -gt 1 ]]; then
	sketchybar --set "$NAME" drawing=false
	return 0
fi

# GUARD dependencies or API key missing
if [[ -z "$GITHUB_TOKEN" ]]; then
	# $GITHUB_TOKEN is saved in .zshenv and therefore available here
	sketchybar --set "$NAME" label="TOKEN?" drawing=true
	return 1
fi

# GUARD only trigger on deactivation or activation of browser
if [[ "$SENDER" = "front_app_switched" ]]; then
	mkdir -p "$HOME/.cache/sketchybar"
	data="$HOME/.cache/sketchybar/front_app2"
	[[ -f "$data" ]] && deactivated_app=$(< "$data")
	activated_app="$INFO"
	echo -n "$activated_app" > "$data"

	[[ "$activated_app" == "Brave Browser" || "$deactivated_app" == "Brave Browser" ]] || return 0

	# when triggered due to opening in browser, wait so notification opened is marked as read
	[[ "$activated_app" == "Brave Browser" ]] && sleep 9
fi

#───────────────────────────────────────────────────────────────────────────────

# DOCS https://docs.github.com/en/rest/activity/notifications?apiVersion=2022-11-28
response=$(curl -sL \
	-H "Accept: application/vnd.github+json" \
	-H "Authorization: Bearer $GITHUB_TOKEN" \
	-H "X-GitHub-Api-Version: 2022-11-28" \
	"https://api.github.com/notifications")

if [[ -z "$response" ]]; then
	sketchybar --set "$NAME" label="?" drawing=true
	return 1
fi
error=$(echo "$response" | jq --raw-output ".message")
if [[ -n "$error" ]]; then
	sketchybar --set "$NAME" label="$error" drawing=true
	return 1
fi

notification_count=$(echo "$response" | jq ". | length")
if [[ $notification_count -eq 0 ]]; then
	sketchybar --set "$NAME" drawing=false
else
	sketchybar --set "$NAME" drawing=true label="$notification_count"
fi
