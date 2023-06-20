#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
#───────────────────────────────────────────────────────────────────────────────

# TODO MANUAL CHANGES
open "$HOME/.zshenv"
BROWSER_APP="Brave Browser"

#───────────────────────────────────────────────────────────────────────────────

osascript -l JavaScript -e 'Application("com.runningwithcrayons.Alfred").revealWorkflow("browser-history-search [ext]")'

# add browser ID here
osascript -l JavaScript -e 'Application("com.runningwithcrayons.Alfred").revealWorkflow("sidenote-tweaks")'

# Import / Change settings
open "chrome-extension://pncfbmialoiaghdehhbnbhkkgmjanfhe/pages/options.html"
open "chrome-extension://hfjbmagddngcpeloejdejnfgbamkjaeg/pages/options.html"
open "chrome-extension://jinjaccalgkegednnccohejagnlnfdag/options/index.html"
open "chrome-extension://epmaefhielclhlnmjofcdapbeepkmggh/options.html"
open "chrome-extension://bijpdibkloghppkbmhcklkogpjaenfkg/html/options.html"
open "chrome-extension://bgnkhhnnamicmpeenaelnjfhikgbkllg/pages/options.html"
open "chrome-extension://gnmdbogfankgjepgglmmfmbnimcmcjle/optionPage/optionPage.html"

# toggle local file URLs here
open "brave://extensions/?id=hfjbmagddngcpeloejdejnfgbamkjaeg"

#───────────────────────────────────────────────────────────────────────────────

# PWAs

open "https://www.netflix.com/browse"
open "https://www.crunchyroll.com/de"
open "https://www.tagesschau.de/multimedia/sendung/tagesschau_20_uhr"
open "https://www.youtube.com/"
open "https://www.twitch.tv/"

# INFO "Vivaldi Apps" is internally still named "Chrome Apps"
[[ "$BROWSER_APP" == "Vivaldi" ]] && browser="Chrome" || browser="$BROWSER_APP"
PWA_FOLDER="$HOME/Applications/$browser Apps.localized"

cd "$PWA_FOLDER" || exit 1
iconsur set Tagesschau.app &>/dev/null
iconsur set Netflix.app &>/dev/null
iconsur set Twitch.app &>/dev/null
iconsur set CrunchyRoll.app &>/dev/null

cp -f "$CUSTOM_ICON_FOLDER/YouTube.icns" "$PWA_FOLDER/YouTube.app/Contents/Resources/app.icns"
touch "$PWA_FOLDER/YouTube.app/Contents/Resources/app.icns"

# TODO change BetterTouchTool for PWAs

#───────────────────────────────────────────────────────────────────────────────

# AUTOMATED CHANGES

# Duti
browserAppId=$(osascript -e "id of app \"$BROWSER_APP\"")
duti -s "$browserAppId" chrome-extension
duti -s "$browserAppId" chrome
duti -s "$browserAppId" webloc all # link files
duti -s "$browserAppId" url all    # link files

# reload karabiner & hammerspoon
karabinerMsg=$(osascript -l JavaScript "$DOTFILE_FOLDER/karabiner/build-karabiner-config.js")
echo "$karabinerMsg"
killall "Hammerspoon"
while pgrep -xq "Hammerspoon"; do sleep 0.1; done
open -a "Hammerspoon"
