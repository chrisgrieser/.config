#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

#───────────────────────────────────────────────────────────────────────────────

tot1=$(osascript -e 'tell application "Tot" to open location "tot://1/content"')

# add preview of note to status bar (similar to the OneThing app)
if [[ -n "$tot1" ]]; then
	icon=""
	preview="$(echo -n "$tot1" |
		head -n1 |
		sed -e 's/- //' -Ee 's/#+ //' |
		cut -c-9)…"
fi

sketchybar --set "$NAME" icon="$icon" label="$preview"
