#!/usr/bin/env zsh

url="$*"
title=$(curl -sL "$url" | grep -o "<title>[^<]*" | cut -d'>' -f2- | tr -d ":/\\,")
[[ -z "$title" ]] && title="Untitled"

# shellcheck disable=1091
source "$HOME/.zshenv" # sources $WD
link_file_path="$WD/$title.url"

#───────────────────────────────────────────────────────────────────────────────

echo "[InternetShortcut]
URL=$url
IconIndex=0" >>"$link_file_path"

open -R "$link_file_path"
