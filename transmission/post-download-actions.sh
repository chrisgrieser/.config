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
find . -mindepth 1 -type directory | while read -r folder; do
	files_in_folder=$(find "$folder" -depth 1 | wc -l | tr -d " ")
	[[ $files_in_folder -eq 1 ]] && mv "$folder"/* "$TR_TORRENT_DIR"
	rmdir "$folder" # only deletes empty folders
done

# QUIT TRANSMISSION, IF NO OTHER ACTIVE TORRENTS
sleep 4 # time for new torrents to be initialized
incomplete_dir=$(defaults read org.m0k.transmission IncompleteDownloadFolder)
active_torrents=$(find "$incomplete_dir" -mindepth 1 -type directory -not -path "**/TV**")
[[ -z "$active_torrents" ]] && killall "Transmission"
