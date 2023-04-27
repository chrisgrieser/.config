#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

url="$*"
title=$(curl -sL "$url" | grep -o "<title>[^<]*" | cut -d'>' -f2- | tr -d ":/\\,")

# shellcheck disable=2154
link_file_path="${default_folder/#\~/$HOME}/$title.url"

{
	echo "[InternetShortcut]"
	echo "URL=$url"
	echo "IconIndex=0"
} >>"$link_file_path"

open -R "$link_file_path"
