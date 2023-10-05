#!/bin/zsh

max_number_of_bkps=5

#───────────────────────────────────────────────────────────────────────────────

timestamp=$(date '+%Y-%m-%d_%H-%M')
bkp_destination="$DATA_DIR/Backups/dotfile bkp" # DATA_DIR defined in zshenv
mkdir -p "$bkp_destination"
backup_file="$bkp_destination/dotfile-bkp_$timestamp.zip"

# directory change necessary to avoid zipping root folder
# https://unix.stackexchange.com/questions/245856/zip-a-file-without-including-the-parent-directory
[[ -e "$bkp_destination" ]] || mkdir -p "$bkp_destination"
cd "$HOME/.config" || return 1
# hidden files on the first level have to named explicitly since not matched
# by globbing
zip -r --quiet "$backup_file" ./* ./.{gitmodule,gitignore}

#───────────────────────────────────────────────────────────────────────────────

# restrict number of backups
cd "$bkp_destination" || return 1
actual_number=$((max_number_of_bkps + 1))
# shellcheck disable=2012
ls -t | tail -n +$actual_number | tr '\n' '\0' | xargs -0 rm
