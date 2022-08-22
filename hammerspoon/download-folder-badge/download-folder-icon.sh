#!/usr/bin/env zsh
# shellcheck disable=SC2012
export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH

cd "$(dirname "$0")" || exit 1

folder="$1"
cache_location="dlFolderLastChange"  # cache necessary to prevent recursion of icon change triggering pathwatcher again

#-------------------------------------------------------------------------------

itemCount=$(ls "$folder" | wc -l)
itemCount=$((itemCount-1)) # reduced by one to account for the "?Icon" file in the folder

[[ ! -e "$cache_location" ]] || touch "$cache_location"
last_change=$(cat "$cache_location")

if [[ $itemCount -gt 0 ]] && [[ -z "$last_change" ]] ; then
	fileicon set "$folder" "with Badge.icns"
	echo "badge" > "$cache_location"
	killall Dock
elif [[ $itemCount -eq 0 ]] && [[ -n "$last_change" ]] ; then
	fileicon set "$folder" "without Badge.icns"
	echo "" > "$cache_location"
	killall Dock
fi
