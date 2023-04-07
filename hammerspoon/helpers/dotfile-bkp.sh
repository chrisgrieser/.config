#!/bin/zsh

max_number_of_bkps=5

#───────────────────────────────────────────────────────────────────────────────

timestamp=$(date '+%Y-%m-%d_%H-%M')
bkp_destination="$DATA_DIR/Backups/dotfile bkp" # DATA_DIR defined in zshenv
backup_file="$bkp_destination/dotfile-bkp_$timestamp.zip"

# directory change necessary to avoid zipping root folder
# https://unix.stackexchange.com/questions/245856/zip-a-file-without-including-the-parent-directory
[[ -e "$bkp_destination" ]] || mkdir -p "$bkp_destination"
cd "$DOTFILE_FOLDER" || return 1

# hidden files on the first level have to named explicitly since not matched
# by globbing
zip -r --quiet "$backup_file" ./* ./.{gitmodule,gitignore}

# restrict number of backups
# shellcheck disable=SC2154
actual_number=$((max_number_of_bkps + 1))
cd "$bkp_destination" || exit 1
# shellcheck disable=SC2012,SC2248
ls -t | tail -n +$actual_number | tr '\n' '\0' | xargs -0 rm

echo -n "$backup_file"
