#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

#───────────────────────────────────────────────────────────────────────────────
# CONFIG
folder="Base"
preview_cutoff_chars=9

#───────────────────────────────────────────────────────────────────────────────

note_count=$(osascript -l JavaScript -e "Application('SideNotes').folders.byName('$folder').notes().length")
current_note=$(osascript -l JavaScript -e "Application('SideNotes').currentNote().text()")

if [[ $note_count -eq 0 ]]; then
	icon=""
	label=""
else
	icon="󰛽"
	label="$note_count"
fi

# add preview of note to status bar (similar to the OneThing app)
if [[ $(echo "$current_note" | wc -l) -eq 1 ]]; then
	preview="$(echo -n "$current_note" |
		sed -e 's/\[ ] //' -e 's/- //' |
		cut -c-$preview_cutoff_chars)…"
	label="$label $preview"
fi

sketchybar --set "$NAME" icon="$icon" label="$label"
