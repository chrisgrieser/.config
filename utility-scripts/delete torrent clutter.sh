#!/bin/zsh
# shellcheck disable=SC2012
export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH
#───────────────────────────────────────────────────────────────────────────────
# INFO https://github.com/transmission/transmission/blob/main/docs/Scripts.md#scripts
#───────────────────────────────────────────────────────────────────────────────

# Config
VIDEO_DIR="$HOME/Downloaded"
SUB_LANG='en'
#───────────────────────────────────────────────────────────────────────────────

# delete clutter
find "$VIDEO_DIR" \
	-name '*.txt' -delete \
	-or -name '*.nfo' -delete \
	-or -name '*.exe' -delete \
	-or -name '*.md' -delete \
	-or -name '*.jpg' -delete \
	-or -name '*.jpeg' -delete \
	-or -name '*.png' -delete
find "$VIDEO_DIR" -name "Sample" -print0 | xargs -0 rm -r # `-delete` does not work for directories, therefore done this way

# download subtitles in newest folder
NEW_FOLDER="$VIDEO_DIR/$(ls -tc "$VIDEO_DIR" | head -n1)"
subliminal download --language "$SUB_LANG" "$NEW_FOLDER"

# if no subtitle, move up
FILES_IN_FOLDER=$(ls "$NEW_FOLDER" | wc -l | tr -d " ")
if [[ $FILES_IN_FOLDER == 1 ]]; then
	mv "$NEW_FOLDER"/* "$VIDEO_DIR"
	rmdir "$NEW_FOLDER"
fi

# quit Transmission, if there are no other torrents
if [[ -z "$(transmission-remote --list)" ]]; then
	killall "Transmission"
fi
