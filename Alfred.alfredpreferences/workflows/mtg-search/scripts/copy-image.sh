#!/usr/bin/env zsh

# shellcheck disable=2154
mkdir -p "$alfred_workflow_cache"
image_file="$alfred_workflow_cache/card-image.png"

curl --silent --location "$1" --output "$image_file"

osascript -e "tell application \"Finder\" to set the clipboard to (POSIX file \"$image_file\")" && 
	echo "success"
