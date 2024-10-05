#!/usr/bin/env zsh

# CONFIG
max_number_of_bkps=100
browser_setting="$HOME/Library/Application Support/BraveSoftware/Brave-Browser"
#───────────────────────────────────────────────────────────────────────────────

# INFO $DATA_DIR defined in .zshenv
isodate=$(date '+%Y-%m-%d')
bkp_destination="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Backups/Browser Bookmarks"
backup_file="$bkp_destination/$isodate.json"

mkdir -p "$bkp_destination"
cp -f "$browser_setting/Default/Bookmarks" "$backup_file"

#───────────────────────────────────────────────────────────────────────────────
# restrict number of backups
cd "$bkp_destination" || return 1
actual_number=$((max_number_of_bkps + 1))
# shellcheck disable=2012
ls -t | tail -n +$actual_number | tr '\n' '\0' | xargs -0 rm
