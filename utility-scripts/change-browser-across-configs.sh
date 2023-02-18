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
	| grep -v "/user.workflow.3BF713ED-02D0-4127-8126-26E36BF15CFC/" \
	| grep -v "$0" \
	# | xargs -I {} sed -i '' "s/$FROM_BROWSER/$TO_BROWSER/g" '{}' 
