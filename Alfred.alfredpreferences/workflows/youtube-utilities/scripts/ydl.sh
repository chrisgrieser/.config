#!/bin/zsh
# shellcheck disable=2154 # $browser_app set in Alfred settings

function notify {
	./notificator --title "yt-dlp" --message "$1" --subtitle "$2"
}

#───────────────────────────────────────────────────────────────────────────────

# cannot use JXA to get browser URL, since sometimes a PWA is frontmost
url=$(osascript -e "tell application \"$browser_app\" to return URL of active tab of front window")

if [[ -z "$url" ]]; then
	./notificator --title "yt-dlp" --message "❌ Tab could not be retrieved."
	return 1
elif [[ ! -d "$download_location" ]]; then
	./notificator --title "yt-dlp" --message "❌ Invalid Download Location."
	return 1
fi

#───────────────────────────────────────────────────────────────────────────────
# DOWNLOAD
notify "yt-dlp" "⏳ Starting Download…"
msg=$(cd "$download_location" && yt-dlp --quiet "$url")
success=$?

if [[ $success -eq 0 ]]; then
	notify "✅ Download finished."
elif ! [[ "$(yt-dlp --update)" =~ "up to date" ]]; then
	notify "ℹ️  yt-dlp not up to date."
	echo -n "brew update && brew upgrade yt-dlp" | pbcopy
else
	afplay "/System/Library/Sounds/Basso.aiff" &
	notify "❌ $msg"
fi
