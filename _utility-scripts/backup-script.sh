#!/bin/zsh

if ! command -v ct &>/dev/null; then print "\033[1;33mchrometerm not installed.\033[0m" && return 1; fi


# CONFIG
LOG_LOCATION="$DATA_DIR/Backups/backups-to-external-drives.log"

#───────────────────────────────────────────────────────────────────────────────
# DETERMINE VOLUME

i=0
while true; do
	VOLUME_NAME="$(df -h | grep -io "\s/Volumes/.*" | cut -c2-)"
	if [[ $(echo "$VOLUME_NAME" | wc -l) -gt 1 ]]; then
		print "\033[1;33mMore than one volume connected.\033[0m"
		return 1
	elif [[ -n "$VOLUME_NAME" ]]; then
		break
	fi

	sleep 0.2
	i=$((i + 1))
	if [[ $i -gt 20 ]]; then
		print "\033[1;33mNo Volume found.\033[0m"
		return 1
	fi
done
print "\033[1;34mBacking up to $VOLUME_NAME…\033[0m"

# determine backup destination
DEVICE_NAME="$(scutil --get ComputerName)"
BACKUP_DEST="$VOLUME_NAME/Backup_$DEVICE_NAME"
mkdir -p "$BACKUP_DEST"
cd "$BACKUP_DEST" || return 1

# Log (on the Mac)
echo -n "Backup: $(date '+%Y-%m-%d %H:%M'), $VOLUME_NAME -- " >>"$LOG_LOCATION"

#───────────────────────────────────────────────────────────────────────────────

# Helper function
errors="" # accumulator for errors
function backup() {
	local bkp_from="$1"
	local bkp_to="$2"
	[[ ! -d "$bkp_from" ]] && errors="$errors\n$bkp_from does not exist."
	echo
	print "\033[1;34m─────────────────────────────────────────────────────────────────────────────"
	echo "Backing up: $bkp_from"
	print "─────────────────────────────────────────────────────────────────────────────\033[0m"
	mkdir -p "$bkp_to"
	# --delete-during the fastest deletion method, --arcive already implies --recursive
	ct rsync --archive --delete-during --progress --human-readable \
		--exclude="*.Trash/*" "$bkp_from" "$bkp_to"
}

#───────────────────────────────────────────────────────────────────────────────
# CONTENT TO BACKUP

# - WARN each command has to sync to individual folders, since otherwise the
#  `--delete` option will override the previous contents
# - WARN All source paths needs to end with a slash to sync folder contents
# - locations defined in zshenv
backup "$HOME/Applications/" ./Homefolder/Applications # user applications
backup "$HOME/.config/" ./Homefolder/config
backup "$VAULT_PATH/" ./Homefolder/main-vault
backup "$PASSWORD_STORE_DIR/" ./Homefolder/password-store
backup "$HOME/RomComs/" ./Homefolder/RomComs

backup "$HOME/Library/Mobile Documents/com~apple~CloudDocs/" ./iCloud-Folder

#───────────────────────────────────────────────────────────────────────────────
echo
print "\033[1;34m─────────────────────────────────────────────────────────────────────────────\033[0m"
echo
[[ -n "$errors" ]] && print "\033[1;31m$errors\033[0m"

# Log (on Mac)
echo "completed: $(date '+%H:%M')" >>"$LOG_LOCATION"

# Log (at Backup Destination)
echo "Backup: $(date '+%Y-%m-%d %H:%M')" >>last_backup.log

# Reminder for Next Backup in 14 days, if there os no next backup reminder
# already (avoids duplicate reminders if backup run twice)
osascript -e'
	set nextDate to (current date) + 14 * (60 * 60 * 24)
	tell application "Reminders"
		set backupReminders to reminders of list "General" where name is "Backup" and completed is false
		if (count of backupReminders) is 0 then
			tell (list "General") to make new reminder with properties {name:"Backup", allday due date:nextDate}
		end if
		quit
	end tell' &>/dev/null

# Notify on Completion
osascript -e 'display notification "" with title "Backup finished." sound name ""'

#───────────────────────────────────────────────────────────────────────────────
