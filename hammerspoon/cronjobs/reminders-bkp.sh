#!/usr/bin/env zsh

# CONFIG
list_name="Tasks"
max_number_of_bkps=60
#───────────────────────────────────────────────────────────────────────────────

isodate=$(date +"%Y-%m-%d")
bkp_destination="$DATA_DIR/Backups/Reminders"
backup_file="$bkp_destination/${isodate}.json"

mkdir -p "$bkp_destination"
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
reminders show "$list_name" --format=json --due-date="today" >>"$backup_file"
reminders show "$list_name" --format=json --due-date="yesterday" >>"$backup_file"

#───────────────────────────────────────────────────────────────────────────────
# restrict number of backups
cd "$bkp_destination" || return 1
actual_number=$((max_number_of_bkps + 1))
# shellcheck disable=2012
ls -t | tail -n +$actual_number | tr '\n' '\0' | xargs -0 rm