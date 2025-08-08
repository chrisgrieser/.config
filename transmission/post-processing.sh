#!/usr/bin/env zsh
# DOCS https://github.com/transmission/transmission/blob/main/docs/Scripts.md#scripts
# TEST torrents: https://webtorrent.io/free-torrents
#───────────────────────────────────────────────────────────────────────────────

action_log="./.post-processing.log"

#───────────────────────────────────────────────────────────────────────────────

# DELETE CLUTTER
cd "$TR_TORRENT_DIR" || return 1 # `$TR_TORRENT_DIR` is where the downloads are placed
find . -E -iregex ".*\.(nfo|md|jpe?g|png|exe|txt)$" -delete
find . -type directory -empty -delete                  # e.g. now empty `Image` folders
find . -type directory -name "Sample" -exec rm -r {} + # Folders with content do not accept `-delete`
sleep 1

# UNNEST IF SINGLE FILE
find . -mindepth 1 -type directory | while read -r folder; do
	files_in_folder=$(find "$folder" -depth 1 | wc -l | tr -d " ")
	if [[ $files_in_folder -eq 1 ]] ; then
		mv -n "$folder"/* "$TR_TORRENT_DIR" # `-n` prevents overwriting
		rmdir "$folder" # only deletes empty folders
		echo "$(date "+%Y-%m-%d %H:%M") Unnested $folder" | tee -a "$action_log"
	fi
done

# RENAME TOP-LEVEL FILES
find "." -maxdepth 1 -name "*.mkv" | while read -r old_name; do
	old_name_no_ext=${old_name%.*}
	new_name=$(
		echo "$old_name_no_ext" |
			cut -c3- | # remove `./`
			tr "._" " " |
			sed -e 's/ *\[[a-zA-Z0-9_]*\] *//g' | # tags for the subbing group
			sed -Ee 's/\(?(1080p).*/\1/' -Ee 's/\(?(720p).*/\1/' # video file info
	)
	new_name="./$new_name.mkv"
	if [[ ! -f "$new_name" ]]; then
		echo "$(date "+%Y-%m-%d %H:%M") $old_name -> $new_name" | tee -a "$action_log"
		command mv "$old_name" "$new_name"
	fi
done

# QUIT TRANSMISSION, IF NO OTHER ACTIVE TORRENTS
sleep 15 # time for new torrents to be initialized
incomplete_dir=$(defaults read org.m0k.transmission IncompleteDownloadFolder)
# exclude `TV`, cause it's a re-appearing special folder in the `Movies` folder
active_torrents=$(find "$incomplete_dir" -mindepth 1 -not -path "**/TV**" -not -name ".DS_Store" -not -name ".localized")
[[ -z "$active_torrents" ]] && killall "Transmission"
