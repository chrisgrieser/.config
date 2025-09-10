#!/usr/bin/env zsh
# DOCS https://github.com/transmission/transmission/blob/main/docs/Scripts.md#scripts
# TEST torrents: https://webtorrent.io/free-torrents
#───────────────────────────────────────────────────────────────────────────────

action_log="./.post-processing.log"

#───────────────────────────────────────────────────────────────────────────────

cd "$TR_TORRENT_DIR" || return 1 # `$TR_TORRENT_DIR` is where the downloads are placed

# DELETE CLUTTER
# my version of `find` does not support `-regex` with `|`, so we search for
# each file type separately
find . \( -name "*.txt" -or -name "*.nfo" -or -name "*.md" -or -name "*.exe" \
	-or -name "*.png" -or -name "*.jp*g" \) -delete -print
find . -type directory -empty -delete -print           # e.g. now empty `	find "." -type d -not -path "**/.git/**" -empty -delete -print` folders
find . -type directory -name "Sample" -exec rm -r {} + # Folders with content do not accept `-delete`
sleep 1

# UNNEST IF SINGLE FILE
find . -mindepth 1 -type directory | while read -r folder; do
	files_in_folder=$(find "$folder" -depth 1 | wc -l | tr -d " ")
	if [[ $files_in_folder -eq 1 ]]; then
		command mv -n "$folder"/* "$TR_TORRENT_DIR" # `-n` prevents overwriting
		rmdir "$folder"                             # `rmdir` only deletes empty folders
		echo "$(date "+%Y-%m-%d %H:%M") Unnested $folder" | tee -a "$action_log"
	fi
done

# RENAME TOP-LEVEL FILES
find "." -maxdepth 1 -name "*.mkv" | while read -r old_name; do
	old_name_no_ext=${old_name%.*}
	clean_name=$(
		echo "$old_name_no_ext" |
			cut -c3- | # remove `./`
			tr "._" " " |
			sed 's/ *\[[a-zA-Z0-9_-]*\] *//g' | # tags for the subbing group
			sed -E 's/(1080p|720p).*/\1/' |    # video file info after the resolution info
			tr -s " ()[]"                        # remove leftover spaces or double brackets
	)
	# shellcheck disable=2296 # valid in zsh
	capitalized="${(U)clean_name[1]}${clean_name[2,-1]}"
	new_name="./$capitalized.mkv"
	if [[ ! -f "$new_name" ]]; then
		echo "$(date "+%Y-%m-%d %H:%M") $old_name -> $new_name" | tee -a "$action_log"
		command mv "$old_name" "$new_name"
	fi
done

# QUIT TRANSMISSION, IF NO OTHER ACTIVE TORRENTS
sleep 10 # time for potential new torrents to be initialized
incomplete_dir=$(defaults read org.m0k.transmission IncompleteDownloadFolder)
active_torrents=$(find "$incomplete_dir" -mindepth 1 -not -name ".DS_Store" -not -name ".localized")
[[ -z "$active_torrents" ]] && killall "Transmission"
