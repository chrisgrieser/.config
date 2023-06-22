#!/usr/bin/env zsh
export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH

download_location="${download_location/#\~/$HOME}"
CURRENT_TAB=$(echo -n "$*")

if [[ -z "$CURRENT_TAB" ]] ; then
	echo -n "❌ Tab could not be retrieved."
	return 1
elif ! cd "$download_location" ; then
	echo -n "❌ Invalid Download Location."
	return 1
elif ! [[ "$(yt-dlp -U)" =~ "up to date" ]]; then
	echo -n "ℹ️ yt-dlp not up to date, aborting."
	echo -n "brew update && brew upgrade yt-dlp" | pbcopy
	return 1
fi

osascript -e 'display notification "" with title "⏳ Starting Download…"'

if yt-dlp --quiet "$CURRENT_TAB" ; then
	echo -n "✅ Download finished."
else
	echo -n "❌ Download not possible."
fi
