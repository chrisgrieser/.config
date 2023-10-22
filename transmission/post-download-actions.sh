#!/usr/bin/env zsh
#───────────────────────────────────────────────────────────────────────────────
# INFO https://github.com/transmission/transmission/blob/main/docs/Scripts.md#scripts

# CONFIG
VIDEO_DIR="$HOME/Downloaded"

#───────────────────────────────────────────────────────────────────────────────

# Check requirements
command -v transmission-remote &>/dev/null || touch "./WARN transmission-remote not installed"
cd "$VIDEO_DIR" || return 1

# delete clutter
find . \( -name '*.txt' -or -name '*.nfo' -or -name '*.exe' -or -name '*.md' \
	-or -name '*.jpg' -or -name '*.png' \) -delete
find . -name "Sample" -print0 | xargs -0 rm -r # `-delete` doesn't work for directories

# wait for files being fully moved & identify new folder
sleep 0.5
NEW_FOLDER="$(find . -mindepth 1 -type d -mtime -2m | head -n1)"

# if single file, move up and remove directory
sleep 0.5
FILES_IN_FOLDER=$(find "$NEW_FOLDER" -depth 1 | wc -l | tr -d " ")
if [[ $FILES_IN_FOLDER -eq 1 ]]; then
	mv "$NEW_FOLDER"/* "$VIDEO_DIR"
	rmdir "$NEW_FOLDER"
fi

# quit Transmission, if there are no other torrents active
sleep 5 # time for new torrents to be initialized
torrent_active=$(transmission-remote --list | sed '1d;$d')
[[ -z "$torrent_active" ]] && killall "Transmission"
