#!/usr/bin/env zsh
# CONFIG
logpath_on_mac="$DATA_DIR/Backups/backups-to-external-drives.log"

#───────────────────────────────────────────────────────────────────────────────
# DETERMINE VOLUME

echo "Searching for Volume… "
for _ in {1..100}; do
	volume_name="$(df -h | grep -io "\s/Volumes/.*" | cut -c2-)"
	if [[ $(echo "$volume_name" | wc -l) -gt 1 ]]; then
		print "\033[1;33mMore than one volume connected.\033[0m"
		return 1
	elif [[ -n "$volume_name" ]]; then
		break
	fi
	printf "🬋"
	sleep 0.5
done
echo

if [[ -z "$volume_name" ]]; then
	print "\033[1;33mTimeout, no volume found.\033[0m"
	return 1
else
	print "\033[1;34mBackup volume: $volume_name\033[0m"
	print "\e[1;38;5;247m─────────────────────────────────────────────────────────────────────────────"
fi

#───────────────────────────────────────────────────────────────────────────────
# DETERMINE BACKUP DESTINATION

device_name="$(scutil --get ComputerName)"
backup_dest="$volume_name/Backup_$device_name"
mkdir -p "$backup_dest"
cd "$backup_dest" || return 1
echo -n "Backup: $(date '+%Y-%m-%d %H:%M'), $volume_name -- " >> "$logpath_on_mac"

#───────────────────────────────────────────────────────────────────────────────
# HELPER FUNCTION

errors=""
function backup() {
	local bkp_from="$1"
	local bkp_to="$2"
	if [[ ! -d "$bkp_from" ]]; then
		errors="$errors\n$bkp_from does not exist."
		return 1
	fi
	echo
	print "\e[1;34mBacking up: $bkp_from\e[0m"
	mkdir -p "$bkp_to"

	rsync --archive --delete-during --recursive --progress --human-readable \
		--exclude="*.Trash/*" "$bkp_from" "$bkp_to" ||
		errors="$errors\nProblems occurred for $bkp_from backup."

	print "\e[1;38;5;247m─────────────────────────────────────────────────────────────────────────────"
}

#───────────────────────────────────────────────────────────────────────────────
# CONFIG CONTENT TO BACKUP

# - WARN each command has to sync to individual folders, since otherwise the
# `--delete` option will override the previous contents
# - WARN paths NEEDS TO END WITH A SLASH to sync folder contents
backup "$HOME/Library/Mobile Documents/com~apple~CloudDocs/" ./iCloud-Folder
backup "$HOME/RomComs/" ./Homefolder/RomComs

# need to be backed from Home directory, as iCloud only has symlinks
backup "$HOME/Desktop/" ./Homefolder/Desktop
backup "$HOME/Documents/" ./Homefolder/Documents

# also backup all PERMA-REPOS
while read -r line; do
	repo_path=$(echo "$line" | cut -d, -f2 | sed "s|^~|$HOME|")
	basename="$(basename "$repo_path")"
	backup "$repo_path/" "./perma-repos/$basename"
done < "$HOME/.config/perma-repos.csv"

#───────────────────────────────────────────────────────────────────────────────
# LOG & NOTIFY

echo
if [[ -z "$errors" ]]; then
	echo "completed: $(date '+%H:%M')" >> "$logpath_on_mac"
	echo "Backup: $(date '+%Y-%m-%d %H:%M')" >> "$backup_dest/last_backup.log"
	print "\033[1;32mBackup on $volume_name completed.\033[0m"
	"$ZDOTDIR/notificator" --title "Backup" --message "✅ complete" --sound "Blow"
else
	print "\033[1;31m$errors\033[0m"
	"$ZDOTDIR/notificator" --title "Backup" --message "⚠️ Errors occurred." --sound "Basso"
fi
