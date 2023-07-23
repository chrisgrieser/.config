#!/usr/bin/env zsh

url="$*"
title=$(curl -sL "$url" | grep -o "<title>[^<]*" | cut -d'>' -f2- | tr -d ":/\\,")
[[ -z "$title" ]] && title="Untitled"

# shellcheck disable=2154
link_file_path="$base_folder/$title.url"

#───────────────────────────────────────────────────────────────────────────────

echo "[InternetShortcut]
URL=$url
IconIndex=0" >>"$link_file_path"

open -R "$link_file_path"
