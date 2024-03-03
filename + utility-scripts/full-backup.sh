# CONFIG
LOG_LOCATION="$DATA_DIR/Backups/backups-to-external-drives.log"

#───────────────────────────────────────────────────────────────────────────────
# DETERMINE VOLUME

# check continuously for a volume
i=0
while true; do
	VOLUME_NAME="$(df -h | grep -io "\s/Volumes/.*" | cut -c2-)"
	if [[ $(echo "$VOLUME_NAME" | wc -l) -gt 1 ]]; then
		print "\033[1;33mMore than one volume connected.\033[0m"
		return 1
	elif [[ -n "$VOLUME_NAME" ]]; then
		break
	fi

	sleep 0.5
	i=$((i + 1))
	if [[ $i -gt 15 ]]; then
		print "\033[1;33mNo Volume found.\033[0m"
		return 1
	fi
done
print "\033[1;34mBackup Volume: $VOLUME_NAME\033[0m"

#───────────────────────────────────────────────────────────────────────────────
# DETERMINE BACKUP DESTINATION

# determine backup folder at destination
DEVICE_NAME="$(scutil --get ComputerName)"
BACKUP_DEST="$VOLUME_NAME/Backup_$DEVICE_NAME"
mkdir -p "$BACKUP_DEST"
cd "$BACKUP_DEST" || return 1

# Log (on the Mac)
echo -n "Backup: $(date '+%Y-%m-%d %H:%M'), $VOLUME_NAME -- " >>"$LOG_LOCATION"

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
# - WARN All source paths needs to end with a slash to sync folder contents
# - locations defined in zshenv
backup "$HOME/Applications/" ./Homefolder/Applications # user applications have PWAs
backup "$HOME/.config/" ./Homefolder/config
backup "$VAULT_PATH/" ./Homefolder/main-vault
backup "$PASSWORD_STORE_DIR/" ./Homefolder/password-store
backup "$HOME/RomComs/" ./Homefolder/RomComs

# full iCloud
backup "$HOME/Library/Mobile Documents/com~apple~CloudDocs/" ./iCloud-Folder

#───────────────────────────────────────────────────────────────────────────────
# BACKUP COMPLETED MESSAGE

echo
print "\033[1;34m─────────────────────────────────────────────────────────────────────────────\033[0m"
echo
if [[ -z "$errors" ]] ; then
	print "\033[1;32mBackup on $VOLUME_NAME completed.\033[0m"
else
	print "\033[1;31m$errors\033[0m"
fi

osascript -e 'display notification "" with title "Backup finished." sound name "Blow"'

#───────────────────────────────────────────────────────────────────────────────

# LOG BACKUP ACTIVITY
# on Mac
echo "completed: $(date '+%H:%M')" >>"$LOG_LOCATION"

# at Backup Destination
echo "Backup: $(date '+%Y-%m-%d %H:%M')" >>last_backup.log

# Reminder for Next Backup in 14 days (idempotent, due to multiple backup disks)
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
	count of backupReminders
' &>/dev/null
