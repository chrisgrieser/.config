# CONFIG
log_location="$DATA_DIR/Backups/backups-to-external-drives.log"

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
fi

#───────────────────────────────────────────────────────────────────────────────
# DETERMINE BACKUP DESTINATION

# determine backup folder at destination
device_name="$(scutil --get ComputerName)"
backup_dest="$volume_name/Backup_$device_name"
mkdir -p "$backup_dest"
cd "$backup_dest" || return 1

# Log (on the Mac)
echo -n "Backup: $(date '+%Y-%m-%d %H:%M'), $volume_name -- " >>"$log_location"

#───────────────────────────────────────────────────────────────────────────────
# HELPER FUNCTION

errors="" # accumulator for errors
function backup() {
	local bkp_from="$1"
	local bkp_to="$2"
	[[ ! -d "$bkp_from" ]] && errors="$errors\n$bkp_from does not exist."
	echo
	print "\e[1;38;5;247m─────────────────────────────────────────────────────────────────────────────"
	print "\e[1;34mBacking up: $bkp_from\e[0m"
	mkdir -p "$bkp_to"
	# --delete-during the fastest deletion method, --archive already implies --recursive
	rsync --archive --delete-during --progress --human-readable \
		--exclude="*.Trash/*" "$bkp_from" "$bkp_to"
}

#───────────────────────────────────────────────────────────────────────────────
# CONTENT TO BACKUP

# - WARN each command has to sync to individual folders, since otherwise the
# `--delete` option will override the previous contents
# - WARN paths NEEDS TO END WITH A SLASH to sync folder contents
backup "$HOME/Applications/" ./Homefolder/Applications # user applications have PWAs
backup "$HOME/RomComs/" ./Homefolder/RomComs
backup "$HOME/Library/Mobile Documents/com~apple~CloudDocs/" ./iCloud-Folder

# also backup all perma-repos
while read -r line; do
	repo_path=$(echo "$line" | cut -d, -f2 | sed "s|^~|$HOME|")
	basename="$(basename "$repo_path")"
	backup "$repo_path/" "./Homefolder/$basename"
done <"$HOME/.config/perma-repos.csv"

#───────────────────────────────────────────────────────────────────────────────
# BACKUP COMPLETED MESSAGE

echo
print "\033[1;34m─────────────────────────────────────────────────────────────────────────────\033[0m"
echo
if [[ -z "$errors" ]]; then
	print "\033[1;32mBackup on $volume_name completed.\033[0m"
else
	print "\033[1;31m$errors\033[0m"
fi

osascript -e 'display notification "" with title "Backup finished." sound name "Blow"'

#───────────────────────────────────────────────────────────────────────────────
# LOG BACKUP ACTIVITY

# on Mac
echo "completed: $(date '+%H:%M')" >>"$log_location"

# at backup destination
echo "Backup: $(date '+%Y-%m-%d %H:%M')" >>last_backup.log

# Reminders.app for next backup in 14 days
# (idempotent, due to multiple backup disks)
osascript -e '
	set today to (current date)
	set inTwoWeeks to today + 14 * (60 * 60 * 24)
	tell application "Reminders"
		set theList to (default list)
		set backupReminders to (reminders of theList where name is "Backup" and completed is false and due date is greater than today)
		if (count of backupReminders) is 0 then
			tell theList to make new reminder with properties {name:"Backup", allday due date:inTwoWeeks}
		end if
		quit
	end tell
' &>/dev/null
