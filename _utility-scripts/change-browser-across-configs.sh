#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
#───────────────────────────────────────────────────────────────────────────────

# Duti
browserID="com.brave.Browser"
duti -s "$browserID" chrome-extension
duti -s "$browserID" chrome
duti -s "$browserID" webloc all # link files
duti -s "$browserID" url all    # link files

# reload karabiner
karabinerMsg=$(osascript -l JavaScript "$DOTFILE_FOLDER/karabiner/build-karabiner-config.js")
echo "$karabinerMsg"

# restart hammerspoon
killall "Hammerspoon"
while pgrep -xq "Hammerspoon"; do sleep 0.1; done
open -a "Hammerspoon"
