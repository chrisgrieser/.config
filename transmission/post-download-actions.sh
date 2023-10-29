#!/usr/bin/env zsh
# shellcheck disable=2164
# DOCS https://github.com/transmission/transmission/blob/main/docs/Scripts.md#scripts
#───────────────────────────────────────────────────────────────────────────────

# GUARD

# read download folder from transmission settings
download_folder="$(defaults read org.m0k.transmission DownloadFolder)"
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
find . -type d -name "Sample" -exec rm -r {} + # Folders do not accept `-delete`

# if single file, unnest it
sleep 1
last_folder="$(find . -mindepth 1 -type d -mtime -1m | head -n1)"
files_in_folder=$(find "$last_folder" -depth 1 | wc -l | tr -d " ")
if [[ $files_in_folder -eq 1 ]]; then
	mv "$last_folder"/* "$download_folder"
	rmdir "$last_folder"
fi

#───────────────────────────────────────────────────────────────────────────────
# quit Transmission, if no other active torrents

if [[ ! -x "$(command -v transmission-remote)" ]]; then
	touch "./WARN transmission-remote not installed"
	return 1
fi

sleep 3 # time for new torrents to be initialized
torrent_active=$(transmission-remote --list | sed '1d;$d' | grep -v " Done")
[[ -z "$torrent_active" ]] && killall "Transmission"
