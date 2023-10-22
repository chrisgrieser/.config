#!/bin/zsh
# shellcheck disable=SC2154
if ! command -v fileicon &>/dev/null; then print "\033[1;33mfileicon not installed.\033[0m" && return 1; fi

#───────────────────────────────────────────────────────────────────────────────
# shellcheck disable=1091

# cannot use JXA to get browser URL, since sometimes a PWA is frontmost
source "$HOME/.zshenv" # get BROWSER_APP env var
URL=$(osascript -e "tell application \"$BROWSER_APP\"
	return URL of active tab of front window
end tell")

# GUARD
if [[ -z "$URL" ]]; then
	echo -n "❌ Tab could not be retrieved."
	return 1
elif [[ ! "$URL" =~ "youtu" ]]; then # to match youtu.de and youtube.com
	echo -n "❌ Not a YouTube URL."
	return 1
elif [[ ! -d "$youtube_link_folder" ]] ; then
	echo -n "❌ Download Folder does not exist."
	return 1
fi

YOUTUBE_ID=$(echo "$URL" | cut -d "=" -f2)
TITLE=$(curl -s "$URL" | grep -o "<title>[^<]*" | cut -d'>' -f2- |
tr "/:" "--" | sed -e 's/ - YouTube//' -e 's/amp;//g')
IMAGE_URL="https://img.youtube.com/vi/$YOUTUBE_ID/0.jpg"

#───────────────────────────────────────────────────────────────────────────────

destination="$youtube_link_folder/$TITLE.url"
print "[InternetShortcut]\nURL=$URL\nIconIndex=0" >"$destination"
curl -sL "$IMAGE_URL" >temp.jpg
fileicon -q set "$destination" temp.jpg
rm -f temp.jpg

# return for notification
echo -n "🎞 Saved: $TITLE"
