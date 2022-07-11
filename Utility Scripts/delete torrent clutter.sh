#!/bin/zsh
# shellcheck disable=SC2012
VIDEO_DIR=~'/Video/Downloaded'
SUB_LANG='en'

# ----------------------

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
