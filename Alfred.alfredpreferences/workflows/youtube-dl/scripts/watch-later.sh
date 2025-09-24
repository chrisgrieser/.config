#!/bin/zsh
#───────────────────────────────────────────────────────────────────────────────

function notify {
	./notificator --title "🕑 Watch Later" --message "$1"
}
#───────────────────────────────────────────────────────────────────────────────

# GET URL
# cannot use JXA to get browser URL, since sometimes a PWA is frontmost
# shellcheck disable=2154 # $browser_app set in Alfred settings
url="$(osascript -e "tell application \"$browser_app\" to return URL of active tab of front window" |
	sed 's/&/&amp;/g')" # `&` invalid in .webloc

# GUARD
if [[ -z "$url" ]]; then
	notify "❌ Tab could not be retrieved."
	return 1
elif [[ ! "$url" =~ "youtu" ]]; then # to match youtu.be and youtube.com
	notify "❌ Not a YouTube URL."
	return 1
fi

#───────────────────────────────────────────────────────────────────────────────

# CREATE ICON FILE
youtube_id=$(echo "$url" | cut -d'=' -f2 | cut -d'&' -f1)
title=$(
	curl --silent "$url" |
		grep --only-matching "<title>[^<]*" | cut -d'>' -f2- | # get title key
		tr "/:" "-" |                                         # remove unsafe chars
		sed -e 's/ - YouTube//'                 # cleanup
)
# decode HTML
title=$(osascript -l "JavaScript" -e "'$title'.replace(/&#(\d+);/g, (_, code) => String.fromCharCode(code))")

# shellcheck disable=2154
mkdir -p "$youtube_link_folder"
destination="$youtube_link_folder/$title.webloc"

cat > "$destination" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>URL</key>
	<string>${url}</string>
</dict>
</plist>
EOF

#───────────────────────────────────────────────────────────────────────────────

# SET ICON
image_url="https://img.youtube.com/vi/$youtube_id/0.jpg"
curl --silent --location "$image_url" > icon.jpg

# http://codefromabove.com/2015/03/programmatically-adding-an-icon-to-a-folder-or-file/
# alternative: use `fileicon` cli
sips -i icon.jpg &> /dev/null              # take an image and make it its own icon
DeRez -only icns icon.jpg > tmpicns.rsrc   # extract the icon to its own resource file
Rez -append tmpicns.rsrc -o "$destination" # append resource to the file to icon-ize
SetFile -a C "$destination"                # use the resource to set the icon
rm -f tmpicns.rsrc icon.jpg

#───────────────────────────────────────────────────────────────────────────────

# ALFRED NOTIFICATION
notify "🎞 $title"
