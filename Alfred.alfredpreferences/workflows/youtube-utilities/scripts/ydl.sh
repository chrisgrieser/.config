#!/bin/zsh

function notify {
	./notificator --title "[yt-dlp]" --subtitle "$1" --message "$2"
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

# shellcheck disable=2154 # Alfred var
msg=$(yt-dlp --no-progress --paths="home:$download_folder" "$url" 2>&1)
success=$?
if [[ $success -eq 0 ]]; then
	notify "✅ Download finished" "$url"
else
	# output via Alfred Markdown view
	echo "## ❌ Download failed"
	echo
  # adds two spaces after each line for markdown linebreak
  echo "${msg}  "
fi
