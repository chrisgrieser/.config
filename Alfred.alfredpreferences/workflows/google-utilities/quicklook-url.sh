#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

url="$*"
temppath="/tmp/quicklookURL"

echo "[InternetShortcut]" > "$temppath"
echo "$url" >> "$temppath"
echo "IconIndex=0" >> "$temppath"

qlmanage -p "$temppath"
