#!/bin/zsh
# shellcheck disable=SC2012

# https://github.com/transmission/transmission/blob/main/docs/Scripts.md#scripts

#-------------------------------------------------------------------------------

# to be triggered on finishing a torrent download, e.g. via Transmission.app

# Config
VIDEO_DIR=~'/Downloaded'
SUB_LANG='en'
#-------------------------------------------------------------------------------

export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH

# delete clutter
find "$VIDEO_DIR" \
	-name '*.txt' -delete \
	-or -name '*.nfo' -delete \
	-or -name '*.exe' -delete \
	-or -name '*.md' -delete \
	-or -name '*.jpg' -delete \
	-or -name '*.jpeg' -delete \
	-or -name '*.png' -delete

# delete flag does not work for directories
find "$VIDEO_DIR" -name "Sample" -print0 | xargs -0 rm -r

# download subtitles in newest folder
NEW_FOLDER="$VIDEO_DIR/$(ls -tc "$VIDEO_DIR" | head -n1)"
subliminal download --language "$SUB_LANG" "$NEW_FOLDER"

# if no subtitle, move up
FILES_IN_FOLDER=$(ls "$NEW_FOLDER" | wc -l | tr -d " ")
if [[ $FILES_IN_FOLDER == 1 ]]; then
	mv "$NEW_FOLDER"/* "$VIDEO_DIR"
	rmdir "$NEW_FOLDER"
fi

# quit Transmission
osascript -e 'tell application "Transmission" to quit'
