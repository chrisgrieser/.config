#!/usr/bin/env zsh
export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH
CURRENT_TAB=$(osascript -e 'tell application "Brave Browser" to return URL of active tab of front window')

download_location="${download_location/#\~/$HOME}"
cd "$download_location" || exit 1

youtube-dl --quiet "$CURRENT_TAB" 2>&1
