# https://blog.christovic.com/2021/02/programatically-adding-spotlight.html
# https://github.com/mattprice/dotfiles/blob/master/scripts/spotlight-ignore.rb
# the "VolumeConfiguration.plist" sometimes needs to be recreated

SPOTLIGHT_CONFIG="/System/Volumes/Data/.Spotlight-V100/VolumeConfiguration.plist"

sudo plutil -insert Exclusions.0 -string '/Applications/Utilities/' "$SPOTLIGHT_CONFIG"
sudo plutil -insert Exclusions.0 -string '/Applications/Cisco' "$SPOTLIGHT_CONFIG"
sudo plutil -insert Exclusions.0 -string ~'/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/Dotfiles/Alfred.alfredpreferences/workflows/' "$SPOTLIGHT_CONFIG"
sudo plutil -insert Exclusions.0 -string ~'/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/Backups/' "$SPOTLIGHT_CONFIG"
sudo plutil -insert Exclusions.0 -string ~'/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/Dotfiles/hammerspoon/Spoons/' "$SPOTLIGHT_CONFIG"
sudo plutil -insert Exclusions.0 -string ~'/Library/Mobile Documents/com~apple~CloudDocs/.Trash/' "$SPOTLIGHT_CONFIG"
sudo plutil -insert Exclusions.0 -string ~'/Library/Mobile Documents/com~apple~CloudDocs/Academia/PhD Data/' "$SPOTLIGHT_CONFIG"

sudo launchctl stop com.apple.metadata.mds
sudo launchctl start com.apple.metadata.mds

# show current exclusions
sudo plutil -extract Exclusions xml1 -o - "$SPOTLIGHT_CONFIG"

# remove an exclusion
# sudo plutil -remove Exclusions.{index} "$SPOTLIGHT_CONFIG"

# restart spotlight indexing
sudo mdutil -E -i on /
sudo rm -R "$SPOTLIGHT_CONFIG"
