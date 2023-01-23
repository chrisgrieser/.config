#!/bin/zsh

VOLUME_NAME="$(df -h | grep -io "\s/Volumes/.*" | cut -c2-)"
if [[ $(echo "$VOLUME_NAME" | wc -l) -gt 1 ]] ; then 
	print "\033[1;33mMore than one volume connected.\033[0m"
	exit 1
elif [[ $(echo "$VOLUME_NAME" | wc -l) -gt 1 ]] ; then 
	print "\033[1;33mNo volume connected.\033[0m"
	exit 1
fi

echo "Backing up to $VOLUME_NAME…"

DEVICE_NAME="$(scutil --get ComputerName)"

BACKUP_DEST="$VOLUME_NAME/Backup_$DEVICE_NAME"
mkdir -p "$BACKUP_DEST"
cd "$BACKUP_DEST" || exit 1

# Log (on the Mac)
LOG_LOCATION="$(dirname "$0")/backup.log"
echo -n "Backup: $(date '+%Y-%m-%d %H:%M'), $VOLUME_NAME -- " >>"$LOG_LOCATION"

#───────────────────────────────────────────────────────────────────────────────

function bkp() {
	print -n "\033[1;34m"
	echo
	echo "----------------------------------------------------"
	echo "Backing up: $1"
	echo -n "----------------------------------------------------"
	print "\033[0m"
	mkdir -p "$2"
	rsync --archive --progress --delete -h --exclude="*.Trash/*" "$1" "$2"
}

#───────────────────────────────────────────────────────────────────────────────

# CONTENT TO BACKUP

# WARNING each command has to sync to individual folders, since otherwise
# the --delete option will override the previous contents
# INFO All paths needs to end with a slash
# INFO locations defined in zshenv
bkp "$HOME/Library/Preferences/" ./Library/Preferences
bkp "$HOME/RomComs/" ./Homefolder/RomComs
bkp "$DOTFILE_FOLDER" ./Homefolder/config
bkp "$VAULT_PATH" ./Homefolder/main-vault
bkp "$ICLOUD" ./iCloud-Folder
bkp "$PASSWORD_STORE_DIR" ./Homefolder/password-store
bkp "$HOME/.gnupg/" ./Homefolder/gnupg

#───────────────────────────────────────────────────────────────────────────────

# Log (on Mac)
echo "completed: $(date '+%H:%M')" >>"$LOG_LOCATION"

# Log (at Backup Destination)
echo "Backup: $(date '+%Y-%m-%d %H:%M')" >>last_backup.log

# Reminder for Next Backup in 14 days
osascript -e'
	set nextDate to (current date) + 14 * (60 * 60 * 24)
	tell application "Reminders" 
		tell (list "General") to make new reminder at end with properties {name: "Backup", allday due date: nextDate}
		quit
	end tell' &>/dev/null

# Notify on Completion
osascript -e 'display notification "" with title "Backup finished." sound name "Blow"'
