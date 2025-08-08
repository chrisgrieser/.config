#!/bin/zsh

function notify {
	./notificator --title "yt-dlp" --subtitle "$1" --message "$2"
	[[ "$1" =~ "❌" ]] && afplay "/System/Library/Sounds/Basso.aiff" &
}

#───────────────────────────────────────────────────────────────────────────────

# cannot use JXA to get browser URL, since sometimes a PWA is frontmost
# shellcheck disable=2154 # alfred var
url=$(osascript -e "tell application \"$browser_app\" to return URL of active tab of front window")

if [[ -z "$url" ]]; then
	notify "❌ Tab could not be retrieved."
	return 1
elif [[ ! -x "$(command -v yt-dlp)" ]]; then
	notify "❌ yt-dlp not installed."
	return 1
fi

#───────────────────────────────────────────────────────────────────────────────
# DOWNLOAD
notify "⏳ Downloading…" "$url"

# GUARD in case the download folder has not been set in `.config/yt-dlp/config`,
# save files in `/tmp/` instead of the folder of this Alfred workflow.
cd "/tmp/" || return 1

msg=$(yt-dlp --quiet "$url" 2>&1)
success=$?
if [[ $success -eq 0 ]]; then
	notify "✅ Download finished." "$url"
else
	# output via Alfred Markdown view
	echo "## ❌ Download failed"
	echo
	echo "$url"
	echo "$msg"
fi
