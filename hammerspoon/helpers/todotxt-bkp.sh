#!/bin/zsh

# CONFIG
max_number_of_bkps=400 # backup-intervall is every 2 hours -> ~33 days
bkp_destination="$DATA_DIR/Backups/todotxt" # DATA_DIR defined in zshenv
todotxt_location=$(dirname "$TODOTXT")

# CREATE BACKUP
timestamp=$(date '+%Y-%m-%d_%H-%M')
mkdir -p "$bkp_destination"
cd "$bkp_destination" || return 1
cp -r "$todotxt_location" "$timestamp"

# RESTRICT NUMBER OF BACKUPS
actual_number=$((max_number_of_bkps + 1))
# shellcheck disable=2012
ls -t | tail -n +$actual_number | tr '\n' '\0' | xargs -0 rm -r
