#!/usr/bin/env zsh
# shellcheck disable=2164
# DOCS https://github.com/transmission/transmission/blob/main/docs/Scripts.md#scripts
#───────────────────────────────────────────────────────────────────────────────

# GUARD
download_folder="$(defaults read org.m0k.transmission DownloadFolder)"
[[ -x "$(command -v transmission-remote)" ]] || touch "./WARN transmission-remote not installed"
if [[ -d "$download_folder" ]]; then
	cd "$download_folder"
else
	touch "./WARN Transmission DownloadFolder not found"
	return 1
fi

#───────────────────────────────────────────────────────────────────────────────

# delete clutter
find . \( -name '*.txt' -or -name '*.nfo' -or -name '*.exe' -or -name '*.md' \
	-or -name '*.jpg' -or -name '*.png' \) -delete
# shellcheck disable=2038
find . -name "Sample" | xargs rm -r # `-delete` doesn't work for directories

# wait for files being fully moved & identify new folder
sleep 0.5
new_folder="$(find . -depth 1 -type d -mtime -2m | head -n1)"

# if single file, move up and remove directory
sleep 0.5
files_in_folder=$(find "$new_folder" -depth 1 | wc -l | tr -d " ")
if [[ $files_in_folder -eq 1 ]]; then
	mv "$new_folder"/* "$download_folder"
	rmdir "$new_folder"
fi

#───────────────────────────────────────────────────────────────────────────────

# quit Transmission, if there are no other torrents active
sleep 3 # time for new torrents to be initialized
torrent_active=$(transmission-remote --list | sed '1d;$d' | grep -v " Done")
[[ -z "$torrent_active" ]] && killall "Transmission"
