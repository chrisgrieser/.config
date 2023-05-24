#!/usr/bin/env zsh

open -a "Vivaldi" "vivaldi://sync"
#───────────────────────────────────────────────────────────────────────────────
open -a "Vivaldi" "vivaldi://experiments"
# TODO custom css

#───────────────────────────────────────────────────────────────────────────────

killall "Vivaldi"
while pgrep -xq "Vivaldi" ; do sleep 0.1; done

sed -i '' \
	's/"directory_upgrade":true,"last/"directory_upgrade":true,"extensions_to_open":"torrent:zip:alfredworkflow:ics","last/' \
	"$HOME/Library/Application Support/Vivaldi/Default/Preferences"

open -a "Vivaldi" "vivaldi://settings/appearance/"
echo -n "$HOME/.config/vivaldi" | pbcopy

# TODO paste folder & restart Vivaldi again

#───────────────────────────────────────────────────────────────────────────────
# TODO import settings from these
open -a "Vivaldi" "chrome-extension://pncfbmialoiaghdehhbnbhkkgmjanfhe/pages/options.html"
open -a "Vivaldi" "chrome-extension://bgnkhhnnamicmpeenaelnjfhikgbkllg/pages/options.html"

