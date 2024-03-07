#!/usr/bin/env zsh

# TODO
# $DATA_DIR defined in .zshenv

isoToday=$(date +"%Y-%m-%d")
backup_location="${DATA_DIR}/Backups/Reminders/${isoToday}.json"

reminders --format=json --only-completed --due-date
