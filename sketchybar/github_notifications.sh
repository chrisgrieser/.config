#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
#───────────────────────────────────────────────────────────────────────────────
# Count of GitHub notifications
# DOCS: https://docs.github.com/en/rest/activity/notifications?apiVersion=2022-11-28
# CONFIG: https://github.com/settings/notifications
#───────────────────────────────────────────────────────────────────────────────

if ! command -v yq &>/dev/null; then
	sketchybar --set "$NAME" icon="" label="yq not found"
	return 1
fi

# INFO $GITHUB_TOKEN is saved in .zshenv and therefore available here
notification_count=$(curl -L \
	-H "Accept: application/vnd.github+json" \
	-H "Authorization: Bearer $GITHUB_TOKEN" \
	-H "X-GitHub-Api-Version: 2022-11-28" \
	"https://api.github.com/notifications" |
	yq ". | length")

sketchybar --set "$NAME" icon="" label="$notification_count"
