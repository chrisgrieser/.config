#!/usr/bin/env zsh
# INFO
# - Bookmarks need to be at the location for Chrome, so Alfred can pick them up.
# - Updated for Alfred via `touch -h $chrome_bookmarks`
#───────────────────────────────────────────────────────────────────────────────
# CONFIG
browser_setting="$HOME/Library/Application Support/BraveSoftware/Brave-Browser"

#───────────────────────────────────────────────────────────────────────────────
set -e

my_bookmarks="$browser_setting/Default/Bookmarks"
my_localstate="$browser_setting/Local State"
chrome_bookmarks="$HOME/Library/Application Support/Google/Chrome/Default/Bookmarks"
chrome_localstate="$HOME/Library/Application Support/Google/Chrome/Local State"

mkdir -p "$(dirname "$chrome_bookmarks")"
mkdir -p "$(dirname "$chrome_localstate")"

ln -sf "$my_bookmarks" "$chrome_bookmarks"
ln -sf "$my_localstate" "$chrome_localstate"

echo "Symlinks created."
