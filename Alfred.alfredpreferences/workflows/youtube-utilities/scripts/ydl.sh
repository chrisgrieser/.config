#!/bin/zsh
# shellcheck disable=2154 # Alfred var

function notify {
	./notificator --title "[yt-dlp]" --subtitle "$1" --message "$2"
	[[ "$1" =~ "❌" ]] && afplay "/System/Library/Sounds/Basso.aiff" &
}

#───────────────────────────────────────────────────────────────────────────────

# cannot use JXA to get browser URL, since sometimes a PWA is frontmost
# shellcheck disable=2154 # alfred var
url=$(osascript -e "tell application \"$browser_app\" to return URL of active tab of front window")
title=$(osascript -e "tell application \"$browser_app\" to return title of active tab of front window")

if [[ -z "$url" ]]; then
	notify "❌ Tab could not be retrieved."
	return 1
elif [[ ! -x "$(command -v yt-dlp)" ]]; then
	notify "❌ yt-dlp not installed."
	return 1
fi

#───────────────────────────────────────────────────────────────────────────────
# DOWNLOAD
notify "⏳ Downloading…" "$title"

uid=$(uuidgen)

cache="$alfred_workflow_cache"
yt-dlp --quiet --paths="home:$download_folder" "$url" \
	--progress --no-color --newline \
	--progress-template="%(info.title)s;%(progress._default_template)s" \
	1> "$cache/$uid.stdout" 2> "$cache/$uid.stderr"
success=$?

if [[ $success -eq 0 ]]; then
	notify "✅ Download finished" "$url"
else
	# output via Alfred Markdown view
	echo "### ❌ Download failed"
	cat "$cache/$uid.stderr" |
		# markdown formatting: bold & two trailing spaces for linebreak
		sed -e 's/$/  /g' -e 's/\[/**[/g' -e 's/\]/]**/g' -Ee "s/(ERROR|WARNING):/**&**/"
fi

# this way, each `.stdout` file represents one ongoing download
rm -f "$cache/$uid.stderr"
rm -f "$cache/$uid.stdout"
