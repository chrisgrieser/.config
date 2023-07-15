#!/bin/zsh
export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH
#───────────────────────────────────────────────────────────────────────────────
# INFO https://github.com/transmission/transmission/blob/main/docs/Scripts.md#scripts
#───────────────────────────────────────────────────────────────────────────────

# CONFIG
VIDEO_DIR="$HOME/Downloaded"
SUB_LANG='en'

#───────────────────────────────────────────────────────────────────────────────

cd "$VIDEO_DIR" || exit 1

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
find . -name "Sample" -print0 | xargs -0 rm -r # `-delete` does not work for directories, therefore using xargs

# wait for files being fully moved & identify new folder
sleep 1
NEW_FOLDER="$(find . -type d -mtime -1m | head -n1)"

# download subtitles for all files in that folder
subliminal download --language "$SUB_LANG" "$NEW_FOLDER"

sleep 0.5

# if no subtitle, move up
# shellcheck disable=2012
FILES_IN_FOLDER=$(ls "$NEW_FOLDER" | wc -l | tr -d " ")
if [[ $FILES_IN_FOLDER -eq 1 ]]; then
	mv "$NEW_FOLDER"/* "$VIDEO_DIR"
	rmdir "$NEW_FOLDER"
fi

sleep 0.5

# quit Transmission, if there are no other torrents active
torrent_active=$(transmission-remote --list | grep -v "ID" | grep -v "Sum:")
[[ -z "$torrent_active" ]] && killall "Transmission"
