#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
#───────────────────────────────────────────────────────────────────────────────

# CONFIG
FROM_BROWSER="Brave Browser"
TO_BROWSER="Vivaldi"

FROM_BROWSER_PATH="/BraveSoftware/Brave-Browser/" # ~/Library/Application Support/BraveSoftware/Brave-Browser/Default
TO_BROWSER_PATH="/Vivaldi/"                       # ~/Library/Application Support/Vivaldi/Default

#───────────────────────────────────────────────────────────────────────────────
if [[ ! -f "$TO_BROWSER_PATH" ]] ; then echo "$TO_BROWSER_PATH not right." && return 1; fi 
if ! command -v rg &>/dev/null; then echo "rg not installed." && return 1; fi
#───────────────────────────────────────────────────────────────────────────────

# Open all extensions as tabs for easy installation
# shellcheck disable=2011
ls "$HOME/Library/Application Support/$FROM_BROWSER_PATH/Default/Extensions/" | 
	xargs -I {} open -a "$TO_BROWSER" "https://chrome.google.com/webstore/detail/{}"

#───────────────────────────────────────────────────────────────────────────────
cd "$DOTFILE_FOLDER" || return 1

rg "$FROM_BROWSER" --files-with-matches |
	grep -v "/complex_modifications/" |
	grep -v "/shimmering-obsidian/" |
	grep -v "bootstrap.sh" |
	grep -v "visualized-keyboard-layout/" |
	grep -v "info.plist" |
	grep -v "karabiner/karabiner.json" |
	grep -v ".bttpreset" |
	grep -v "chrome-internal-pages.json" |
	grep -v "jxa.json" |
	grep -v "$0" |
	xargs -I {} sed -i '' "s/$FROM_BROWSER/$TO_BROWSER/g" '{}'
sed -i '' "s/$FROM_BROWSER/$TO_BROWSER/g" "/karabiner/assets/complex_modifications/2 ctrl-leader.yaml"

rg "$FROM_BROWSER_PATH" --files-with-matches |
	grep -v "/user.workflow.3BF713ED-02D0-4127-8126-26E36BF15CFC/" |
	grep -v "$0" |
	xargs -I {} sed -i '' "s|$FROM_BROWSER_PATH|$TO_BROWSER_PATH|g" '{}'

#───────────────────────────────────────────────────────────────────────────────

# reload karabiner
karabinerMsg=$(osascript -l JavaScript "$DOTFILE_FOLDER/karabiner/build-karabiner-config.js")
echo "$karabinerMsg"

# restart hammerspoon
killall "Hammerspoon"
while pgrep -q "Hammerspoon"; do sleep 0.1; done
open -a "Hammerspoon"
