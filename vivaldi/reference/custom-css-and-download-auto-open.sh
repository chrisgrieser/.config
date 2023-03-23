#!/usr/bin/env zsh

open -a "Vivaldi" "vivaldi://experiments"
# TODO custom css

#───────────────────────────────────────────────────────────────────────────────

killall "Vivaldi"
while pgrep -q "Vivaldi" ; do sleep 0.1; done

sed -i '' \
	's/"directory_upgrade":true/"directory_upgrade":true,"extensions_to_open":"torrent:zip:alfredworkflow:ics"/' \
	"$HOME/Library/Application Support/Vivaldi/Default/Preferences"

open -a "Vivaldi" "vivaldi://settings/appearance/"
echo -n "$HOME/.config/vivaldi" | pbcopy

# TODO paste folder & restart Vivaldi again
