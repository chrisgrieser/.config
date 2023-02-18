#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

#───────────────────────────────────────────────────────────────────────────────
# CONFIG
FROM_BROWSER="Brave Browser"
TO_BROWSER="Vivaldi"

#───────────────────────────────────────────────────────────────────────────────
cd "$DOTFILE_FOLDER" || return 1

rg "$FROM_BROWSER" --files-with-matches \
	| grep -v "complex_modifications" \
	| grep -v "Shimmering Obsidian" \
	| grep -v "bootstrap" \
	| grep -v "visualized-keyboard-layout" \
	| grep -v "info.plist" \
	| grep -v "BetterTouchTool" \
	| grep -v "app-specific-behavior.lua" \
	| grep -v "$0" \
	| sed -i '' "s/$FROM_BROWSER/$TO_BROWSER/g" \
