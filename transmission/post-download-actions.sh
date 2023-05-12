#!/bin/zsh
# shellcheck disable=SC2012
export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH
#───────────────────────────────────────────────────────────────────────────────
# INFO https://github.com/transmission/transmission/blob/main/docs/Scripts.md#scripts
#───────────────────────────────────────────────────────────────────────────────

# CONFIG
VIDEO_DIR="$HOME/Downloaded"
SUB_LANG='en'
#───────────────────────────────────────────────────────────────────────────────

# Check requirements
if ! command -v subliminal &>/dev/null; then
	touch "$VIDEO_DIR/subliminal_not_installed"
	return 1
fi
if command -v transmission-remote &>/dev/null; then
	touch "$VIDEO_DIR/transmission-remote_not_installed"
	return 1
fi

cd "$VIDEO_DIR" || exit 1

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

# wait for files being fully moved
i=0
while [[ -z "$NEW_FOLDER" ]]; do
	NEW_FOLDER="$(ls -tc "$VIDEO_DIR" | head -n1)"
	sleep 1
	i=$((i + 1))
	[[ $i -gt 30 ]] && exit 1
done

# download subtitles in newest folder
subliminal download --language "$SUB_LANG" "$NEW_FOLDER"

# if no subtitle, move up
FILES_IN_FOLDER=$(ls "$NEW_FOLDER" | wc -l | tr -d " ")
if [[ $FILES_IN_FOLDER -eq 1 ]]; then
	mv "$NEW_FOLDER"/* "$VIDEO_DIR"
	rmdir "$NEW_FOLDER"
fi

# quit Transmission, if there are no other torrents active
sleep 0.5
torrent_active=$(transmission-remote --list | grep -v "ID" | grep -v "Sum:")
[[ -z "$torrent_active" ]] && killall "Transmission"
