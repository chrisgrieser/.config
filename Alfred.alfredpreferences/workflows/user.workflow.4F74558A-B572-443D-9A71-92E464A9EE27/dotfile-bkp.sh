#!/bin/zsh

timestamp=$(date '+%Y-%m-%d_%H-%M')
dotfile_bkp_destination="${dotfile_bkp_destination/#\~/$HOME}"
backup_path="$dotfile_bkp_destination/dotfile-bkp_$timestamp.zip"
dotfile_folder="${dotfile_folder/#\~/$HOME}"

# directory change necessary to avoid zipping root folder
# https://unix.stackexchange.com/questions/245856/zip-a-file-without-including-the-parent-directory
[[ -e "$dotfile_bkp_destination" ]] || mkdir -p "$dotfile_bkp_destination"
cd "$dotfile_folder" || exit 1
zip -r "$backup_path" ./*

# restrict number of backups
# shellcheck disable=SC2154
actual_number=$((max_number_of_bkps + 1))
cd "$dotfile_bkp_destination" || exit 1
# shellcheck disable=SC2012,SC2248
ls -t | tail -n +$actual_number | tr '\n' '\0' | xargs -0 rm

echo -n "$backup_path"
