#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

folder="Base"
count=$(osascript -l JavaScript -e "Application('SideNotes').folders.byName(\"$folder\").notes().length")

if [[ $count -eq 0 ]]; then
	icon=""
	count=""
else
	icon="ﯻ"
fi

sketchybar --set "$NAME" icon="$icon" label="$count"
