#!/usr/bin/env zsh
# shellcheck disable=SC2012
export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH

folder="$1"
icons_path=~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/Custom Icons/Download Folder"
cache_location="/Library/Caches/dlFolderLastChange"  # cache necessary to prevent recursion of icon change triggering pathwatcher again

#-------------------------------------------------------------------------------

echo "$icons_path/with Badge.icns"
echo "$icons_path/without Badge.icns"

itemCount=$(ls "$folder" | wc -l)
itemCount=$((itemCount-1)) # reduced by one to account for the "?Icon" file in the folder



[[ ! -e "$cache_location" ]] || touch "$cache_location"
if [[ $itemCount -gt 0 ]] ; then
	echo "badge" > "$cache_location"
fi
last_change=$(cat "$cache_location")

if [[ $itemCount -gt 0 ]] && [[ -z "$last_change" ]] ; then
	fileicon set "$folder" "$icons_path/with Badge.icns"
	echo "badge" > "$cache_location"
	killall Dock
elif [[ $itemCount -eq 0 ]] && [[ -n "$last_change" ]] ; then
	fileicon set "$folder" "$icons_path/without Badge.icns"
	echo "" > "$cache_location"
	killall Dock
fi
