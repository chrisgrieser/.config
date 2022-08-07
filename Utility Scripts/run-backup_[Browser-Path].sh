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

# Brew Dumps
BREWDUMP_PATH="$BACKUP_DEST/install lists"
mkdir -p "$BREWDUMP_PATH"
brew bundle dump --force --file "$BREWDUMP_PATH"/Brewfile_"$DEVICE_NAME"
npm list -g --parseable | sed "1d" | sed -E "s/.*\///" > "$BREWDUMP_PATH/NPMfile_$DEVICE_NAME"
echo "Brewfile and NPM-File dumped at \"$BREWDUMP_PATH\""

# rsync function
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
bkp ~'/Library/Preferences/' ./Preferences
bkp ~'/Library/Fonts/' ./Fonts
mkdir -p ./Homefolder
bkp ~'/Games/' ./Homefolder/Games
bkp ~'/Video/' ./Homefolder/Video
bkp ~'/RomComs/' ./Homefolder/RomComs
bkp ~'/Library/Mobile Documents/com~apple~CloudDocs/' ./iCloud-Folder
bkp ~'/dotfiles/' ./dotfiles

# =========================

# Log (on Mac)
echo "completed: $(date '+%H:%M')" >> "$LOG_LOCATION"
log_date="$(date '+%Y-%m-%d %H:%M')"
osascript -e "tell application id \"com.runningwithcrayons.Alfred\" to set configuration \"last_backup\" to value \"$log_date\" in workflow \"de.chris-grieser.backup-utility\" "

# Log (on Backup Destination)
echo "Backup: $(date '+%Y-%m-%d %H:%M')" >> last_backup.log

# Notify on Completion
osascript -e 'display notification "" with title "Backup finished."'
afplay "/System/Library/Sounds/Blow.aiff"
