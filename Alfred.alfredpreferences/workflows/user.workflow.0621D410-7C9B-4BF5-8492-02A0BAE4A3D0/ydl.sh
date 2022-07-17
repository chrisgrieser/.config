#!/usr/bin/env zsh
export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH
download_location="${download_location/#\~/$HOME}"
CURRENT_TAB=$(osascript -e 'tell application "Brave Browser" to return URL of active tab of front window')

[[ -z "$CURRENT_TAB" ]] && exit 1
cd "$download_location" || exit 1

youtube-dl "$CURRENT_TAB" 2>&1
