#!/bin/zsh
# shellcheck disable=SC2154

URL="$*"
YOUTUBE_ID=$(echo "$URL" | cut -d "=" -f2)
TITLE=$(curl -s "$URL" | grep -o "<title>[^<]*" | cut -d'>' -f2- | tr "/:" "--" | sed -e 's/ - YouTube//' | sed -e 's/amp;//g' )
IMAGE_URL="https://img.youtube.com/vi/$YOUTUBE_ID/0.jpg"

# if non-existing folder (e.g. different device) save in working directory instead
youtube_link_folder="${youtube_link_folder/#\~/$HOME}"
if [[ -d "$youtube_link_folder" ]] ; then
	BOOKMARK_PATH="${youtube_link_folder/#\~/$HOME}"
else
	BOOKMARK_PATH="${working_directory/#\~/$HOME}"
fi
BOOKMARK_PATH="$BOOKMARK_PATH/$TITLE.url"

# shellcheck disable=SC2028
echo "[InternetShortcut]\nURL=$URL\nIconIndex=0" > "$BOOKMARK_PATH"
curl -sL "$IMAGE_URL" > temp.jpg
fileicon -q set "$BOOKMARK_PATH" temp.jpg
rm -f temp.jpg

# return for notification
echo -n "$TITLE"
