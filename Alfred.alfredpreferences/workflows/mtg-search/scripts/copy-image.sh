#!/usr/bin/env zsh

# shellcheck disable=2154
mkdir -p "$alfred_workflow_cache"
image_file="$alfred_workflow_cache/last-copied-card.png"

image_url="$1"
curl --silent --location "$image_url" --output "$image_file"

osascript -e "tell application \"Finder\" to set the clipboard to (POSIX file \"$image_file\")" &&
	echo "success"
