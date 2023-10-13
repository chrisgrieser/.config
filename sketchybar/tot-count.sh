#!/usr/bin/env zsh

# ensure that this counter does not launch Tot
pgrep -xq "Tot" || return 0

#───────────────────────────────────────────────────────────────────────────────

dots=""
for i in {1..7}; do
	content=$(osascript -e "tell application \"Tot\" to open location \"tot://$i/content\"")
	[[ -n "$content" ]] && dots="$dots"
done
echo "hii"

sketchybar --set "$NAME" icon="$dots"
