#!/usr/bin/env zsh
# INFO displays a preview of the current Tot content

tot1=$(osascript -e 'tell application "Tot" to open location "tot://1/content"')
[[ -n "$tot1" ]] && count=1 || count=0

for i in {2..7}; do
	content=$(osascript -e "tell application \"Tot\" to open location \"tot://$i/content\"")
	[[ -n "$content" ]] && count=$((count + 1))
done

if [[ -n "$tot1" ]]; then
	icon="󱗜"
	preview="$(echo -n "$tot1" |
		head -n1 |
		sed -e 's/- //' -Ee 's/#+ //' |
		cut -c-9)…"
fi
[[ $count -eq 0 ]] && count=""

sketchybar --set "$NAME" icon="$icon" label="$count  $preview"
