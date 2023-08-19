#!/usr/bin/env zsh
# shellcheck disable=2154

CURRENT_TAB=$(osascript -l JavaScript "./scripts/get-url-from-browser.js" &)

if [[ -z "$CURRENT_TAB" ]]; then
	echo -n "❌ Tab could not be retrieved."
	return 1
elif [[ ! -d "$download_location" ]]; then
	echo -n "❌ Invalid Download Location."
	return 1
fi

osascript -e 'display notification "" with title "⏳ Starting Download…"'

msg=$(cd "$download_location" && yt-dlp --quiet "$CURRENT_TAB")

# shellcheck disable=2181
if [[ $? -eq 0 ]]; then
	echo -n "✅ Download finished."
elif ! [[ "$(yt-dlp --update)" =~ "up to date" ]]; then
	echo -n "ℹ️ yt-dlp not up to date."
	echo -n "brew update && brew upgrade yt-dlp" | pbcopy
else
	afplay "/System/Library/Sounds/Basso.aiff" &
	echo -n "❌ $msg"
fi
