#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
#───────────────────────────────────────────────────────────────────────────────

# GUARD only trigger on deactivation or activation of browser
if [[ "$SENDER" = "front_app_switched" ]]; then
	mkdir -p "$HOME/.cache/sketchybar"
	data="$HOME/.cache/sketchybar/front_app2"
	[[ -f "$data" ]] && deactivated_app=$(<"$data")
	echo -n "$INFO" >"$data"
	[[ "$INFO" != "Brave Browser" && "$deactivated_app" != "Brave Browser" ]] && return 0
fi

# GUARD dependencies or API key missing
if ! command -v yq &>/dev/null; then
	sketchybar --set "$NAME" icon=" " label="yq not found"
	return 1
elif [[ -z "$GITHUB_TOKEN" ]]; then
	# $GITHUB_TOKEN is saved in .zshenv and therefore available here
	sketchybar --set "$NAME" icon=" " label="GITHUB_TOKEN not set"
	return 1
fi

# when triggered due to opening in browser, wait so notification opened is marked as read
[[ "$SENDER" == "front_app_switched" && "$INFO" == "Brave Browser" ]] && sleep 5

#───────────────────────────────────────────────────────────────────────────────

# DOCS https://docs.github.com/en/rest/activity/notifications?apiVersion=2022-11-28
notification_count=$(curl -sL \
	-H "Accept: application/vnd.github+json" \
	-H "Authorization: Bearer $GITHUB_TOKEN" \
	-H "X-GitHub-Api-Version: 2022-11-28" \
	"https://api.github.com/notifications" |
	yq ". | length")

if [[ $notification_count -eq 0 ]]; then
	icon=""
	label=""
	pad=0
else
	icon=""
	label="$notification_count"
	pad=15
fi

sketchybar --set "$NAME" icon="$icon" label="$label" background.padding_right=$pad
