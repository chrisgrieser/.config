#!/bin/zsh

# cannot use JXA to get browser URL, since sometimes a PWA is frontmost
# shellcheck disable=2154 # $browser_app set in Alfred settings
url=$(osascript -e "tell application \"$browser_app\" to return URL of active tab of front window")

if [[ -z "$url" ]]; then
	echo -n "❌ Tab could not be retrieved."
	return 1
elif [[ ! -d "$download_location" ]]; then
	echo -n "❌ Invalid Download Location."
	return 1
fi

#───────────────────────────────────────────────────────────────────────────────
# DOWNLOAD
./notificator --title "yt-dlp" --message "⏳ Starting Download…" --subtitle "$url"
msg=$(cd "$download_location" && yt-dlp --quiet "$url")
success=$?

if [[ $success -eq 0 ]]; then
	echo -n "✅ Download finished."
elif ! [[ "$(yt-dlp --update)" =~ "up to date" ]]; then
	echo -n "ℹ️  yt-dlp not up to date."
	echo -n "brew update && brew upgrade yt-dlp" | pbcopy
else
	afplay "/System/Library/Sounds/Basso.aiff" &
	echo -n "❌ $msg"
fi
