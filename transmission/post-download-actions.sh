#!/usr/bin/env zsh
# DOCS https://github.com/transmission/transmission/blob/main/docs/Scripts.md#scripts
# TEST torrents: https://webtorrent.io/free-torrents
#───────────────────────────────────────────────────────────────────────────────

# DELETE CLUTTER & UNNEST SINGLE FILE

cd "$TR_TORRENT_DIR" || return 1 # $TR_TORRENT_DIR is where the downloads are stored
find -E . -regex ".*\.(nfo|md|jpe?g|png|exe|txt)$" -delete
find . -type d -empty -delete                  # e.g. `Image` folders now empty
find . -type d -name "Sample" -exec rm -r {} + # Folders with content not accept `-delete`

sleep 1
# transmission does not store the downloaded file in a variable, we determine it
# by checking for a folder last modified in the last minute
last_folder="$(find . -mindepth 1 -type d -mtime -1m | head -n1)"

files_in_folder=$(find "$last_folder" -depth 1 | wc -l | tr -d " ")
if [[ $files_in_folder -eq 1 ]]; then
	mv "$last_folder"/* "$TR_TORRENT_DIR"
	rmdir "$last_folder"
fi

#───────────────────────────────────────────────────────────────────────────────
# QUIT TRANSMISSION, IF NO OTHER ACTIVE TORRENTS

export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
if [[ ! -x "$(command -v transmission-remote)" ]]; then
	touch "./transmission-cli not installed (brew install transmission-cli)"
	return 1
fi

sleep 3 # time for new torrents to be initialized
torrent_active=$(transmission-remote --list | sed '1d;$d' | grep -v " Done")
[[ -z "$torrent_active" ]] && killall "Transmission"
