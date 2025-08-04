#!/bin/zsh

# cannot use JXA to get browser URL, since sometimes a PWA is frontmost
# shellcheck disable=2154 # $browser_app set in Alfred settings
api_url=$(osascript -e "tell application \"$browser_app\" to return URL of active tab of front window")

# GUARD
if [[ -z "$api_url" ]]; then
	echo -n "❌ Tab could not be retrieved."
	return 1
elif [[ ! "$api_url" =~ "youtu" ]]; then # to match youtu.be and youtube.com
	echo -n "❌ Not a YouTube URL."
	return 1
elif [[ ! -d "$youtube_link_folder" ]]; then
	echo -n "❌ Download Folder does not exist."
	return 1
fi

#───────────────────────────────────────────────────────────────────────────────

# CREATE ICON FILE
youtube_id=$(echo "$api_url" | cut -d"=" -f2)
title=$(
	curl --silent "$api_url" |
		grep --only-matching "<title>[^<]*" | cut -d'>' -f2- | # get title key
		tr "/:" "--" |                                         # remove unsafe chars
		sed -e 's/ - YouTube//' -e 's/amp;//g'                 # cleanup
)

destination="$youtube_link_folder/$title.url"
print "[InternetShortcut]\nURL=$api_url\nIconIndex=0" >"$destination"

#───────────────────────────────────────────────────────────────────────────────

# SET ICON
image_url="https://img.youtube.com/vi/$youtube_id/0.jpg"
curl -sL "$image_url" >icon.jpg

# http://codefromabove.com/2015/03/programmatically-adding-an-icon-to-a-folder-or-file/
# alternative: use `fileicon` cli
sips -i icon.jpg &>/dev/null               # take an image and make it its own icon
DeRez -only icns icon.jpg >tmpicns.rsrc    # extract the icon to its own resource file
Rez -append tmpicns.rsrc -o "$destination" # append resource to the file to icon-ize
SetFile -a C "$destination"                # use the resource to set the icon
rm -f tmpicns.rsrc icon.jpg

# return for notification
echo -n "🎞 Saved: $title"
