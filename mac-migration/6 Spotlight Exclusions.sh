# https://blog.christovic.com/2021/02/programatically-adding-spotlight.html
# https://github.com/mattprice/dotfiles/blob/master/scripts/spotlight-ignore.rb
# the "VolumeConfiguration.plist" sometimes needs to be recreated

SPOTLIGHT_CONFIG="/System/Volumes/Data/.Spotlight-V100/VolumeConfiguration.plist"

# restart spotlight indexing (this also requires writing exclusions again)

sudo mdutil -E -i on /
sudo rm -R "$SPOTLIGHT_CONFIG"

sleep 1
function addExclusion() {
	sudo plutil -insert Exclusions.0 -string "$1" "$SPOTLIGHT_CONFIG"
}

addExclusion '/Applications/Utilities/'
addExclusion '/Applications/Cisco'
addExclusion "/Volumes/Externe A"
addExclusion "/Volumes/Externe B"
addExclusion "/Volumes/Externe C"
addExclusion "$DOTFILE_FOLDER/Alfred.alfredpreferences/workflows/"
addExclusion "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/Backups/"
addExclusion "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/vim-data/undo"
addExclusion "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/vim-data/view"
addExclusion "$HOME/Library/Mobile Documents/com~apple~CloudDocs/.Trash/"
addExclusion "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Academia/PhD Data/"

#-------------------------------------------------------------------------------

# show current exclusions
SPOTLIGHT_CONFIG="/System/Volumes/Data/.Spotlight-V100/VolumeConfiguration.plist"
sudo plutil -extract Exclusions xml1 -o - "$SPOTLIGHT_CONFIG"

# remove an exclusion
# sudo plutil -remove Exclusions.{index} "$SPOTLIGHT_CONFIG"
