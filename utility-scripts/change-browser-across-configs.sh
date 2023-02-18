#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

#───────────────────────────────────────────────────────────────────────────────
# CONFIG
FROM_BROWSER="Brave Browser"
TO_BROWSER="Vivaldi"

#───────────────────────────────────────────────────────────────────────────────
cd "$DOTFILE_FOLDER" || return 1

rg "$FROM_BROWSER" --files-with-matches \
	| grep -v "/complex_modifications/" \
	| grep -v "/shimmering-obsidian/" \
	| grep -v "bootstrap.sh" \
	| grep -v "visualized-keyboard-layout/" \
	| grep -v "info.plist" \
	| grep -v "karabiner/karabiner.json" \
	| grep -v ".bttpreset" \
	| grep -v "app-specific-behavior.lua" \
	| grep -v "jxa.json" \
	| grep -v "$0" \
	| xargs -I {} sed -i '' "s/$FROM_BROWSER/$TO_BROWSER/g" '{}' 
