# INFO
# Stuff only to needed to run when a new browser is installed
#───────────────────────────────────────────────────────────────────────────────
# CONFIG
browser="Brave Browser"
pwa_folder="$HOME/Applications/Brave Browser Apps.localized"

#───────────────────────────────────────────────────────────────────────────────

# MANUAL
open -a "BetterTouchTool" # change PWAs
osascript -l JavaScript -e 'Application("com.runningwithcrayons.Alfred").revealWorkflow("browser-history-search [3rd-Party]")'

#───────────────────────────────────────────────────────────────────────────────

# PWAs
open "https://www.netflix.com/browse"
open "https://www.crunchyroll.com/de"
open "https://www.tagesschau.de/multimedia/sendung/tagesschau_20_uhr"
open "https://www.youtube.com/"

# INFO "Vivaldi Apps" is internally still named "Chrome Apps"

cd "$pwa_folder" || exit 1
iconsur set Tagesschau.app &>/dev/null
iconsur set Netflix.app &>/dev/null
iconsur set CrunchyRoll.app &>/dev/null

cp -f "$CUSTOM_ICON_FOLDER/YouTube.icns" "$pwa_folder/YouTube.app/Contents/Resources/app.icns"
touch "$pwa_folder/YouTube.app/Contents/Resources/app.icns"

# Duti
browserAppId=$(osascript -e "id of app \"$browser\"")
duti -s "$browserAppId" chrome-extension
duti -s "$browserAppId" chrome
duti -s "$browserAppId" webloc all # link files
duti -s "$browserAppId" url all    # link files

# reload karabiner & hammerspoon
karabinerMsg=$(osascript -l JavaScript "$HOME/.config/karabiner/build-karabiner-config.js")
echo "$karabinerMsg"
killall "Hammerspoon"
while pgrep -xq "Hammerspoon"; do sleep 0.1; done
open -a "Hammerspoon"
