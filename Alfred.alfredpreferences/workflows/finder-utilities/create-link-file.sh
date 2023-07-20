#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

#───────────────────────────────────────────────────────────────────────────────

url="$*"
title=$(curl -sL "$url" | grep -o "<title>[^<]*" | cut -d'>' -f2- | tr -d ":/\\,")
[[ -z "$title" ]] && title="Untitled"

source "$HOME/.zshenv" # sources $WD
link_file_path="$WD/$title.url"

#───────────────────────────────────────────────────────────────────────────────

echo "[InternetShortcut]
URL=$url
IconIndex=0" >>"$link_file_path"

open -R "$link_file_path"
