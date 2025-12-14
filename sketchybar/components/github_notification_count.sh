#!/usr/bin/env zsh

# CONFIG
_export_github_token

#───────────────────────────────────────────────────────────────────────────────

function set_bar {
	icon=""
	[[ -z "$1" ]] && icon=""
	sketchybar --set "$NAME" icon="$icon" label="$1"
}

#───────────────────────────────────────────────────────────────────────────────

# not on projector
if [[ $(system_profiler SPDisplaysDataType | grep -c Resolution) -gt 1 ]]; then
	set_bar ""
	return 0
fi

# GUARD if app-switch, only trigger on deactivation of Brave
if [[ "$SENDER" = "front_app_switched" ]]; then
	mkdir -p "$HOME/.cache/sketchybar"
	data="$HOME/.cache/sketchybar/front_app2"
	[[ -f "$data" ]] && deactivated_app=$(<"$data")
	echo -n "$INFO" >"$data"
	[[ "$deactivated_app" != "Brave Browser" ]] && return 0
fi

if [[ -z "$GITHUB_TOKEN" ]]; then
	set_bar "NO TOKEN"
	return 1
fi

# in office, spotty internet on wake
[[ "$SENDER" == "system_woke" ]] && sleep 5

#───────────────────────────────────────────────────────────────────────────────


# DOCS https://docs.github.com/en/rest/activity/notifications?apiVersion=2022-11-28
response=$(curl --silent --location \
	-H "Accept: application/vnd.github+json" \
	-H "Authorization: Bearer $GITHUB_TOKEN" \
	-H "X-GitHub-Api-Version: 2022-11-28" \
	"https://api.github.com/notifications")

if [[ -z "$response" ]]; then
	set_bar "󰣼"
	return 1
fi
error=$(echo "$response" | jq --raw-output ".message")
if [[ -n "$error" ]]; then
	set_bar " $error"
	return 1
fi

notification_count=$(echo "$response" | jq ". | length")
if [[ $notification_count -eq 0 ]]; then
	set_bar ""
else
	set_bar "$notification_count"
fi
