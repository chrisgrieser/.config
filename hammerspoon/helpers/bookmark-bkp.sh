#!/bin/zsh

max_number_of_bkps=5
browser="BraveSoftware/Brave-Browser"

#───────────────────────────────────────────────────────────────────────────────

bkp_destination="$DATA_DIR/Backups/Browser Bookmarks" # DATA_DIR defined in zshenv
timestamp=$(date '+%Y-%m-%d_%H-%M')
backup_file="$bkp_destination/Browser-Bookmarks_$timestamp"
mkdir -p "$bkp_destination"
cp -f "$HOME/Library/Application Support/$browser/Default/Bookmarks" "$backup_file"

#───────────────────────────────────────────────────────────────────────────────
# restrict number of backups
cd "$bkp_destination" || return 1
actual_number=$((max_number_of_bkps + 1))
# shellcheck disable=2012
ls -t | tail -n +$actual_number | tr '\n' '\0' | xargs -0 rm
