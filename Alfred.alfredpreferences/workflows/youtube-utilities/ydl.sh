#!/usr/bin/env zsh
export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH

download_location="${download_location/#\~/$HOME}"
CURRENT_TAB=$(osascript -l JavaScript "./get-url-from-browser.js")

if [[ -z "$CURRENT_TAB" ]] ; then
	echo -n "❌ Tab could not be retrieved."
	return 1
elif ! cd "$download_location" ; then
	echo -n "❌ Invalid Download Location."
	return 1
fi

osascript -e 'display notification "" with title "⏳ Starting Download…"'

if yt-dlp --quiet "$CURRENT_TAB" ; then
	open "$download_location"
	echo -n "✅ Download finished."
elif ! [[ "$(yt-dlp -U)" =~ "up to date" ]]; then
	echo -n "ℹ️ yt-dlp not up to date."
	echo -n "brew update && brew upgrade yt-dlp" | pbcopy
else
	echo -n "❌ Download not possible."
fi
