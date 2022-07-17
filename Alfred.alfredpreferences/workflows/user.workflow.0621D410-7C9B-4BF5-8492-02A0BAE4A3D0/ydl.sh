#!/usr/bin/env zsh
export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH
download_location="${download_location/#\~/$HOME}"
CURRENT_TAB=$(osascript -e 'tell application "Brave Browser" to return URL of active tab of front window')

[[ -n "$CURRENT_TAB" ]] || exit 1
cd "$download_location" || exit 1

if youtube-dl --quiet "$CURRENT_TAB" ; then
	echo "✅ Download finished."
else
	echo "❌ Not possible"
fi
