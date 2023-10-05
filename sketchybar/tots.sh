#!/usr/bin/env zsh
# INFO displays a preview of the current Tot content

tot1=$(osascript -e 'tell application "Tot" to open location "tot://1/content"')
if [[ -n "$tot1" ]]; then
	icon="󱗜"
	preview="$(echo -n "$tot1" |
		head -n1 |
		sed -e 's/- //' -Ee 's/#+ //' |
		cut -c-9)…"
fi

sketchybar --set "$NAME" icon="$icon" label="$preview"
