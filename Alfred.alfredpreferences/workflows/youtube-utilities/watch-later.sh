#!/bin/zsh
# shellcheck disable=SC2154

if ! command -v fileicon &>/dev/null; then print "\033[1;33mfileicon not installed.\033[0m" && return 1; fi

URL="$*"
YOUTUBE_ID=$(echo "$URL" | cut -d "=" -f2)
TITLE=$(curl -s "$URL" | grep -o "<title>[^<]*" | cut -d'>' -f2- | tr "/:" "--" | sed -e 's/ - YouTube//' | sed -e 's/amp;//g')
IMAGE_URL="https://img.youtube.com/vi/$YOUTUBE_ID/0.jpg"

[[ -d "$youtube_link_folder" ]] &&
	destination="$youtube_link_folder" ||
	destination="$fallback_folder"

#───────────────────────────────────────────────────────────────────────────────

destination="$destination/$TITLE.url"
print "[InternetShortcut]\nURL=$URL\nIconIndex=0" >"$destination"
curl -sL "$IMAGE_URL" >temp.jpg
fileicon -q set "$destination" temp.jpg
rm -f temp.jpg

# return for notification
echo -n "$TITLE"
