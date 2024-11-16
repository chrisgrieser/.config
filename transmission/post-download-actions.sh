#!/usr/bin/env zsh
# DOCS https://github.com/transmission/transmission/blob/main/docs/Scripts.md#scripts
# TEST torrents: https://webtorrent.io/free-torrents
#───────────────────────────────────────────────────────────────────────────────

# DELETE CLUTTER
cd "$TR_TORRENT_DIR" || return 1 # `$TR_TORRENT_DIR` is where the downloads are placed
find -E . -iregex ".*\.(nfo|md|jpe?g|png|exe|txt)$" -delete
find . -type directory -empty -delete                  # e.g. now empty `Image` folders
find . -type directory -name "Sample" -exec rm -r {} + # Folders with content do not accept `-delete`
sleep 1

# UNNEST IF SINGLE FILE
find . -mindepth 1 -type d | while read -r folder; do
	files_in_folder=$(find "$folder" -depth 1 | wc -l | tr -d " ")
	[[ $files_in_folder -eq 1 ]] && mv "$folder"/* "$TR_TORRENT_DIR"
	rmdir "$folder" # only deletes empty folders
done

# QUIT TRANSMISSION, IF NO OTHER ACTIVE TORRENTS
# REQUIRED enabled remote access in transmission settings
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
if [[ ! -x "$(command -v transmission-remote)" ]]; then
	touch "./transmission-cli not installed (brew install transmission-cli)"
	return 1
fi
sleep 3 # time for new torrents to be initialized
torrent_active=$(transmission-remote --list | sed '1d;$d' | grep -v " Done")
[[ -z "$torrent_active" ]] && killall "Transmission"
