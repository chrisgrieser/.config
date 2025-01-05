#!/bin/zsh
# shellcheck disable=2154 # alfred vars

function notify {
	./notificator --title "yt-dlp" --message "$1" --subtitle "$2"
	[[ "$1" =~ "❌" ]] && afplay "/System/Library/Sounds/Basso.aiff" &
}

#───────────────────────────────────────────────────────────────────────────────

# cannot use JXA to get browser URL, since sometimes a PWA is frontmost
url=$(osascript -e "tell application \"$browser_app\" to return URL of active tab of front window")

if [[ -z "$url" ]]; then
	notify "❌ Tab could not be retrieved."
	return 1
elif [[ ! -d "$download_location" ]]; then
	notify "❌ Invalid Download Location."
	return 1
elif [[ ! -x "$(command -v yt-dlp)" ]]; then 
	notify "❌ yt-dlp not installed."
	return 1
fi

#───────────────────────────────────────────────────────────────────────────────
# DOWNLOAD
notify "⏳ Starting Download…" "$url"
msg=$(cd "$download_location" && yt-dlp --quiet "$url")
success=$?

if [[ $success -eq 0 ]]; then
	notify "✅ Download finished."
elif ! [[ "$(yt-dlp --update)" =~ "up to date" ]]; then
	notify "ℹ️ yt-dlp not up to date."
	echo -n "brew update && brew upgrade yt-dlp" | pbcopy
else
	notify "❌ $msg"
fi
