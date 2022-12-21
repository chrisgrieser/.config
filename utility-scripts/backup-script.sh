#!/bin/zsh
DEVICE_NAME="$(scutil --get ComputerName)"

# Backup location
VOLUME_NAME="$*"
BACKUP_DEST="${VOLUME_NAME/#\~/$HOME}/Backup_$DEVICE_NAME"
mkdir -p "$BACKUP_DEST"
cd "$BACKUP_DEST" || exit 1

# Log (on the Mac)
LOG_LOCATION="$(dirname "$0")/backup.log"
echo -n "Backup: $(date '+%Y-%m-%d %H:%M'), $VOLUME_NAME -- " >>"$LOG_LOCATION"

function bkp() {
	echo "----------------------------------------------------"
	echo "👉 starting: $1"
	echo "----------------------------------------------------"
	mkdir -p "$2"
	rsync --archive --progress --delete -h --exclude="*.Trash/*" "$1" "$2"
}

#───────────────────────────────────────────────────────────────────────────────

# CONTENT TO BACKUP

# WARNING each command has to sync to individual folders, since otherwise
# the --delete option will override the previous contents
# INFO All paths needs to end with a slash
bkp "$HOME/Library/Preferences/" ./Library/Preferences
bkp "$HOME/RomComs/" ./Homefolder/RomComs
bkp "$DOTFILE_FOLDER" ./Homefolder/.config
bkp "$VAULT_PATH" ./Homefolder/main-vault
bkp "$ICLOUD" ./iCloud-Folder
bkp "$PASSWORD_STORE_DIR" ./.password-store
bkp "$HOME/.gnupg/" ./.gnupg

#───────────────────────────────────────────────────────────────────────────────

echo "----------------------------------------------------"

# Brew Dumps
BREWDUMP_PATH="$BACKUP_DEST/installed-apps-and-packages"
mkdir -p "$BREWDUMP_PATH"
brew bundle dump --force --file "$BREWDUMP_PATH/Brewfile_$DEVICE_NAME"
npm list -g --parseable | sed "1d" | sed -E "s/.*\///" >"$BREWDUMP_PATH/NPMfile_$DEVICE_NAME"
pip3 list --not-required | tail -n+3 | grep -vE "Pillow|pip|pybind|setuptools|six|wheel" | cut -d" " -f1 >"$BREWDUMP_PATH/Pip3file_$DEVICE_NAME"
echo "Brewfile, NPM-File, and Pip3-File dumped at \"$BREWDUMP_PATH\""

#───────────────────────────────────────────────────────────────────────────────

# Log (on Mac)
echo "completed: $(date '+%H:%M')" >>"$LOG_LOCATION"
log_date="$(date '+%Y-%m-%d %H:%M')"
osascript -e "tell application id \"com.runningwithcrayons.Alfred\" to set configuration \"last_backup\" to value \"$log_date\" in workflow \"de.chris-grieser.backup-utility\" "

# Log (at Backup Destination)
echo "Backup: $(date '+%Y-%m-%d %H:%M')" >>last_backup.log

# Reminder for Next Backup in 14 days
osascript -e'
	set nextDate to (current date) + (60 * 60 * 24) * 14
	tell application "Reminders" to tell (list "General")
		make new reminder at end with properties {name: "Backup", due date: nextDate}
		quit
	end tell' &>/dev/null

# Notify on Completion
osascript -e 'display notification "" with title "Backup finished." sound name "Blow"'
