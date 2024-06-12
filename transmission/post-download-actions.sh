#!/usr/bin/env zsh
# DOCS https://github.com/transmission/transmission/blob/main/docs/Scripts.md#scripts
#───────────────────────────────────────────────────────────────────────────────

cd "$TR_TORRENT_DIR" || return 1

# delete clutter
find -E . -regex ".*\.(nfo|md|jpe?g|png|exe|txt)$" -delete
find . -type d -empty -delete                  # e.g. `Image` folders now empty
find . -type d -name "Sample" -exec rm -r {} + # Folders with content not accept `-delete`

# if single file, unnest it
sleep 1
files_in_folder=$(find . -depth 1 | wc -l | tr -d " ")
if [[ $files_in_folder -eq 1 ]]; then
	mv ./* /..
	rmdir "$TR_TORRENT_DIR"
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
