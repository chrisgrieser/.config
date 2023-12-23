export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
# DOCS https://github.com/transmission/transmission/blob/main/docs/Scripts.md#scripts
#───────────────────────────────────────────────────────────────────────────────

# read download folder from transmission settings
download_folder="$(defaults read org.m0k.transmission DownloadFolder)"
cd "$download_folder" || return 1

#───────────────────────────────────────────────────────────────────────────────

# delete clutter
find -E . -regex ".*\.(nfo|md|jpe?g|png|exe)$" -delete
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
	touch "./transmission-cli not installed (brew install transmission-cli)"
	return 1
fi

sleep 3 # time for new torrents to be initialized
torrent_active=$(transmission-remote --list | sed '1d;$d' | grep -v " Done")
[[ -z "$torrent_active" ]] && killall "Transmission"
