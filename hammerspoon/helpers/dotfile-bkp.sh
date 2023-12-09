#!/usr/bin/env bash

# CONFIG
max_number_of_bkps=5
bkp_destination="$DATA_DIR/Backups/dotfile bkp" # DATA_DIR defined in zshenv
dotfile_location="$HOME/.config"

#───────────────────────────────────────────────────────────────────────────────

timestamp=$(date '+%Y-%m-%d_%H-%M')
backup_file="$bkp_destination/dotfile-bkp_$timestamp.zip"

# directory change necessary to avoid zipping root folder
# https://unix.stackexchange.com/questions/245856/zip-a-file-without-including-the-parent-directory
mkdir -p "$bkp_destination"
cd "$dotfile_location" || return 1
setopt globdots
zip -r --quiet "$backup_file" ./*

#───────────────────────────────────────────────────────────────────────────────

# restrict number of backups
cd "$bkp_destination" || return 1
actual_number=$((max_number_of_bkps + 1))
# shellcheck disable=2012
ls -t | tail -n +$actual_number | tr '\n' '\0' | xargs -0 rm
