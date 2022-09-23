#!/bin/zsh
DEVICE_NAME="$(scutil --get ComputerName)"

# Backup location
VOLUME_NAME="$*"
BACKUP_DEST="${VOLUME_NAME/#\~/$HOME}/Backup_$DEVICE_NAME"
mkdir -p "$BACKUP_DEST"
cd "$BACKUP_DEST" || exit 1

# Log (on the Mac)
LOG_LOCATION="$(dirname "$0")/backup.log"
echo -n "Backup: $(date '+%Y-%m-%d %H:%M'), $VOLUME_NAME -- " >> "$LOG_LOCATION"

function bkp () {
	echo "-------------------------------------------"
	echo "⏺ starting: $1"
	rsync --archive --progress --delete -h --exclude=".Trash/*" --exclude="*/.Trash/*" "$1" "$2"
	echo "-------------------------------------------"
}

# =========================
# Content to Backup

# ⚠️ each command has to sync to individual folders, since otherwise
# the --delete option will override the previous contents
mkdir -p ./Library
bkp ~'/Library/Preferences/' ./Library/Preferences
bkp ~'/Library/Fonts/' ./Library/Fonts
mkdir -p ./Homefolder
bkp ~'/Downloaded/' ./Homefolder/Downloaded
bkp ~'/RomComs/' ./Homefolder/RomComs
bkp ~'/dotfiles/' ./Homefolder/dotfiles
bkp ~'/Main Vault/' "./Homefolder/Main Vault"
bkp ~'/Library/Mobile Documents/com~apple~CloudDocs/' ./iCloud-Folder

# Brew Dumps
BREWDUMP_PATH="$BACKUP_DEST/install lists"
mkdir -p "$BREWDUMP_PATH"
brew bundle dump --force --file "$BREWDUMP_PATH/Brewfile_$DEVICE_NAME"
npm list -g --parseable | sed "1d" | sed -E "s/.*\///" > "$BREWDUMP_PATH/NPMfile_$DEVICE_NAME"
pip3 list --not-required | tail -n+3 | grep -vE "Pillow|pip|pybind|setuptools|six|wheel" | cut -d" " -f1 > "$BREWDUMP_PATH/Pip3file_$DEVICE_NAME"
echo "Brewfile, NPM-File, and Pip3-File dumped at \"$BREWDUMP_PATH\""

# =========================

# Log (on Mac)
echo "completed: $(date '+%H:%M')" >> "$LOG_LOCATION"
log_date="$(date '+%Y-%m-%d %H:%M')"
osascript -e "tell application id \"com.runningwithcrayons.Alfred\" to set configuration \"last_backup\" to value \"$log_date\" in workflow \"de.chris-grieser.backup-utility\" "

# Log (on Backup Destination)
echo "Backup: $(date '+%Y-%m-%d %H:%M')" >> last_backup.log

# Reminder for Next Backup in 14 days
osascript -e'
	set today to current date
	set nextDate to today + (60 * 60 * 24) * 14
	tell application "Reminders" to tell (list "General")
		make new reminder at end with properties {name: "Backup", due date: nextDate}
		quit
	end tell
' &> /dev/null

# Notify on Completion
osascript -e 'display notification "" with title "Backup finished." sound name "Blow"'
