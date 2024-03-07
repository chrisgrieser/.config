#!/usr/bin/env zsh

list_name="Default" # CONFIG

# INFO $DATA_DIR defined in .zshenv
today=$(date +"%Y-%m-%d")
backup_location="${DATA_DIR}/Backups/Reminders/${today}.json"

reminders show "$list_name" --format=json --only-completed --due-date="$today" \
	>"$backup_location"
