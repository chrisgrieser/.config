#!/bin/zsh
export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH
#───────────────────────────────────────────────────────────────────────────────
# INFO https://github.com/transmission/transmission/blob/main/docs/Scripts.md#scripts

# CONFIG
VIDEO_DIR="$HOME/Downloaded"
SUB_LANG='en'

#───────────────────────────────────────────────────────────────────────────────

cd "$VIDEO_DIR" || return 1

# Check requirements
if ! command -v subliminal &>/dev/null; then
	touch "./WARN subliminal_not_installed"
	return 1
elif ! command -v transmission-remote &>/dev/null; then
	touch "./WARN transmission-remote_not_installed"
	return 1
fi

# delete clutter
find . \
	-name '*.txt' -delete \
	-or -name '*.nfo' -delete \
	-or -name '*.exe' -delete \
	-or -name '*.md' -delete \
	-or -name '*.jpg' -delete \
	-or -name '*.jpeg' -delete \
	-or -name '*.png' -delete
# `-delete` does not work for directories, therefore using xargs
find . -name "Sample" -print0 | xargs -0 rm -r 

# wait for files being fully moved & identify new folder
sleep 1
NEW_FOLDER="$(find . -mindepth 1 -type d -mtime -2m | head -n1)"

# download subtitles for all files in that folder
subliminal download --language "$SUB_LANG" "$NEW_FOLDER"

sleep 0.5

# if no subtitle, move up
FILES_IN_FOLDER=$(find "$NEW_FOLDER" -mindepth 1 -not -name ".DS_Store" | wc -l | tr -d " ")
if [[ $FILES_IN_FOLDER -eq 1 ]]; then
	mv "$NEW_FOLDER"/* "$VIDEO_DIR"
	rmdir "$NEW_FOLDER"
fi

sleep 0.5

# quit Transmission, if there are no other torrents active
torrent_active=$(transmission-remote --list | grep -v "ID" | grep -v "Sum:")
[[ -z "$torrent_active" ]] && killall "Transmission"
