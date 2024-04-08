#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

# CONFIG
list_name="Tasks"

#───────────────────────────────────────────────────────────────────────────────

# INFO $DATA_DIR defined in .zshenv
today=$(date +"%Y-%m-%d")
backup_location="${DATA_DIR}/Backups/Reminders/${today}.json"

reminders show "$list_name" --format=json --due-date="today" >>"$backup_location"
reminders show "$list_name" --format=json --due-date="yesterday" >>"$backup_location"
