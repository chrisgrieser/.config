#!/bin/zsh

timestamp=`date '+%Y-%m-%d_%H-%M'`
resolved_bkp_dest=~`echo -n $backup_destination | sed -e "s/~//"`
backup_path="$resolved_bkp_dest""/Sublime-Prefs-Backup_""$timestamp"".zip"
preference_folder_path=~`echo -n $preference_folder_path | sed -e "s/~//"`

# directory change necessary to avoid zipping root folder
# https://unix.stackexchange.com/questions/245856/zip-a-file-without-including-the-parent-directory
cd $preference_folder_path
zip -r $backup_path ./*

# restrict number of backups
actual_number=$((max_number_of_bkps + 1))
cd $resolved_bkp_dest
ls -t | tail -n +$actual_number | tr '\n' '\0' | xargs -0 rm

echo -n "$backup_path"

