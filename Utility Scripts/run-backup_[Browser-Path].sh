#!/bin/zsh
DEVICE_NAME="$(scutil --get ComputerName)"

# Backup location
INPUT="$*" # volume name
BACKUP_DEST="${INPUT/#\~/$HOME}"/Backup_"$DEVICE_NAME"
mkdir -p "$BACKUP_DEST"
cd "$BACKUP_DEST" || exit 1

# Log (on the Mac)
LOG_LOCATION="$(dirname "$0")/backup.log"
echo -n "Backup: $(date '+%Y-%m-%d %H:%M'), $INPUT -- " >> "$LOG_LOCATION"

# Brew Dumps
BREWDUMP_PATH="$BACKUP_DEST/install lists"
mkdir -p "$BREWDUMP_PATH"
brew bundle dump --force --file "$BREWDUMP_PATH"/Brewfile_"$DEVICE_NAME"
npm list -g --parseable | sed "1d" | sed -E "s/.*\///" > "$BREWDUMP_PATH/NPMfile_$DEVICE_NAME"
echo "Brewfile and NPM-File dumped at \"$BREWDUMP_PATH\""

# rsync function
function bkp () {
	# ⚠️ `--delete` option will remove backup when source folder is empty
	# `-hhh` highes level of human readable
	rsync --archive --progress --delete -h --exclude="*/.Trash/*" "$1" "$2"
}

# =========================
# Content to Backup

# ⚠️ each command has to sync to individual folders, since otherwise
# the --delete option will override the previous contents
bkp ~'/Library/Preferences/' ./Preferences
bkp ~'/Library/Application Support/Alfred/Workflow Data/com.vdesabou.spotify.mini.player/' ./Spotify-Mini-Player
bkp ~'/Library/Application Support/BraveSoftware/Brave-Browser/Default/' ./Browser-Default-Folder
bkp ~'/Library/Fonts/' ./Fonts
mkdir -p ./Homefolder
bkp ~'/Games/' ./Homefolder/Games
bkp ~'/Video/' ./Homefolder/Video
bkp ~'/RomComs/' ./Homefolder/RomComs
bkp ~'/Library/Mobile Documents/com~apple~CloudDocs/' ./iCloud-Folder

# =========================

# Log (on Device)
echo "completed: $(date '+%H:%M')" >> "$LOG_LOCATION"
osascript -e 'tell application id "com.runningwithcrayons.Alfred" to set configuration "last_backup" to value "'"$(date '+%Y-%m-%d %H:%M')"'" in workflow "de.chris-grieser.backup-utility" '

# Log (on Backup Destination)
echo "Backup: $(date '+%Y-%m-%d %H:%M')" >> last_backup.log

# Notify on Completion
osascript -e 'display notification "" with title "Backup finished." subtitle "" sound name ""'
