#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

#───────────────────────────────────────────────────────────────────────────────
# CONFIG
FROM_BROWSER="Brave Browser"
TO_BROWSER="Vivaldi"

FROM_BROWSER_PATH="/BraveSoftware/Brave-Browser/" # ~/Library/Application Support/BraveSoftware/Brave-Browser/Default
TO_BROWSER_PATH="/Vivaldi/" # ~/Library/Application Support/Vivaldi/Default

#───────────────────────────────────────────────────────────────────────────────
cd "$DOTFILE_FOLDER" || return 1

# rg "$FROM_BROWSER" --files-with-matches \
# 	| grep -v "/complex_modifications/" \
# 	| grep -v "/shimmering-obsidian/" \
# 	| grep -v "bootstrap.sh" \
# 	| grep -v "visualized-keyboard-layout/" \
# 	| grep -v "info.plist" \
# 	| grep -v "karabiner/karabiner.json" \
# 	| grep -v ".bttpreset" \
# 	| grep -v "app-specific-behavior.lua" \
# 	| grep -v "jxa.json" \
# 	| grep -v "$0" \
# 	| xargs -I {} sed -i '' "s/$FROM_BROWSER/$TO_BROWSER/g" '{}' 

rg "$FROM_BROWSER_PATH" --files-with-matches \
	| grep -v "/user.workflow.3BF713ED-02D0-4127-8126-26E36BF15CFC/" \
	| grep -v "$0" \
	| xargs -I {} sed -i '' "s/$FROM_BROWSER_PATH/$TO_BROWSER_PATH/g" '{}' 
