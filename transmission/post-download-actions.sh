#!/usr/bin/env zsh
# DOCS https://github.com/transmission/transmission/blob/main/docs/Scripts.md#scripts
#───────────────────────────────────────────────────────────────────────────────

# GUARD
# read download folder from transmission settings
download_folder="$(defaults read org.m0k.transmission DownloadFolder)"
if [[ -d "$download_folder" ]]; then
	# shellcheck disable=2164
	cd "$download_folder"
else
	touch "./WARN Transmission DownloadFolder not found"
	return 1
fi

#───────────────────────────────────────────────────────────────────────────────

# DELETE CLUTTER
find -E . -iregex ".*\.(nfo|md|txt|jpe?g|png)$" -delete
find . -type d -name "Sample" -exec rm -r {} + # Folders do not accept `-delete`

# IF SINGLE FILE, UNNEST IT
sleep 1
last_folder="$(find . -mindepth 1 -type d -mtime -1m | head -n1)"
files_in_folder=$(find "$last_folder" -depth 1 | wc -l | tr -d " ")
if [[ $files_in_folder -eq 1 ]]; then
	mv "$last_folder"/* "$download_folder"
	rmdir "$last_folder"
fi

#───────────────────────────────────────────────────────────────────────────────
# QUIT TRANSMISSION, IF NO OTHER ACTIVE TORRENTS

# INFO `test -x /transmission-remote` does not work reliably
if ! command -v transmission-remote &> /dev/null; then
	touch "./WARN transmission-cli not installed"
	return 1
fi

sleep 3 # time for new torrents to be initialized
torrent_active=$(transmission-remote --list | sed '1d;$d' | grep -v " Done")
[[ -z "$torrent_active" ]] && killall "Transmission"
