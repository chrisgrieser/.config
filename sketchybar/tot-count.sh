#!/usr/bin/env zsh
# INFO displays a preview of the current Tot content

dots=""
for i in {1..7}; do
	content=$(osascript -e "tell application \"Tot\" to open location \"tot://$i/content\"")
	[[ -n "$content" ]] && dots="$dots"
done

sketchybar --set "$NAME" icon="$dots"
