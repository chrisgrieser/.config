#!/usr/bin/env zsh
# DOCS https://github.com/transmission/transmission/blob/main/docs/Scripts.md#scripts
# TEST torrents: https://webtorrent.io/free-torrents
#───────────────────────────────────────────────────────────────────────────────

# DELETE CLUTTER
cd "$TR_TORRENT_DIR" || return 1 # `$TR_TORRENT_DIR` is where the downloads are placed
find . -E -iregex ".*\.(nfo|md|jpe?g|png|exe|txt)$" -delete
find . -type directory -empty -delete                  # e.g. now empty `Image` folders
find . -type directory -name "Sample" -exec rm -r {} + # Folders with content do not accept `-delete`
sleep 1

# RENAME FILES
rename_log="./rename.log" # CONFIG
date=$(date "+%Y-%m-%d %H:%M")
find . -mindepth 1 -name "*.mkv" -mmin -1000 | while read -r old_name; do
	new_name=$(
		basename "$old_name" ".mkv" |
			sed -e 's/\[[a-zA-Z0-9_]*\]//g' | # tags for the subbing group
			tr "._" " " |
			sed -Ee 's/(1080p).*/\1/I' -Ee 's/(720p).*/\1/I'
	)
	new_name="$new_name.mkv"
	if [[ ! -f "$new_name" ]]; then
		echo "$date: $old_name -> $new_name" | tee -a "$rename_log"
		# command mv "$old_name" "$new_name"
	fi
done

# UNNEST IF SINGLE FILE
find . -mindepth 1 -type directory | while read -r folder; do
	files_in_folder=$(find "$folder" -depth 1 | wc -l | tr -d " ")
	[[ $files_in_folder -eq 1 ]] && mv "$folder"/* "$TR_TORRENT_DIR"
	rmdir "$folder" # only deletes empty folders
done

# QUIT TRANSMISSION, IF NO OTHER ACTIVE TORRENTS
sleep 15 # time for new torrents to be initialized
incomplete_dir=$(defaults read org.m0k.transmission IncompleteDownloadFolder)
# exclude `TV`, cause it's a re-appearing special folder in the `Movies` folder
active_torrents=$(find "$incomplete_dir" -mindepth 1 -not -path "**/TV**" -not -name ".DS_Store" -not -name ".localized")
[[ -z "$active_torrents" ]] && killall "Transmission"
