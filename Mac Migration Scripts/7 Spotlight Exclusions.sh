# https://blog.christovic.com/2021/02/programatically-adding-spotlight.html
# https://github.com/mattprice/dotfiles/blob/master/scripts/spotlight-ignore.rb
# the "VolumeConfiguration.plist" sometimes needs to be recreated

SPOTLIGHT_CONFIG="/System/Volumes/Data/.Spotlight-V100/VolumeConfiguration.plist"

# restart spotlight indexing (this also requires writing exclusions again)

sudo mdutil -E -i on /
sudo rm -R "$SPOTLIGHT_CONFIG"

sleep 1

sudo plutil -insert Exclusions.0 -string '/Applications/Utilities/' "$SPOTLIGHT_CONFIG"
sudo plutil -insert Exclusions.0 -string '/Applications/Cisco' "$SPOTLIGHT_CONFIG"
sudo plutil -insert Exclusions.0 -string ~'/dotfiles/Alfred.alfredpreferences/workflows/' "$SPOTLIGHT_CONFIG"
sudo plutil -insert Exclusions.0 -string ~'/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/Backups/' "$SPOTLIGHT_CONFIG"
sudo plutil -insert Exclusions.0 -string ~'/Library/Mobile Documents/com~apple~CloudDocs/.Trash/' "$SPOTLIGHT_CONFIG"
sudo plutil -insert Exclusions.0 -string ~'/Library/Mobile Documents/com~apple~CloudDocs/Academia/PhD Data/' "$SPOTLIGHT_CONFIG"
sudo plutil -insert Exclusions.0 -string "/Volumes/Externe A" "$SPOTLIGHT_CONFIG"
sudo plutil -insert Exclusions.0 -string "/Volumes/Externe B" "$SPOTLIGHT_CONFIG"
sudo plutil -insert Exclusions.0 -string "/Volumes/Externe C" "$SPOTLIGHT_CONFIG"
sudo plutil -insert Exclusions.0 -string ~"/dotfiles/Utility Scripts/less-bottom.app" "$SPOTLIGHT_CONFIG"
sudo plutil -insert Exclusions.0 -string ~"/dotfiles/Utility Scripts/Obsidian-Opener.app" "$SPOTLIGHT_CONFIG"

#-------------------------------------------------------------------------------

# show current exclusions
SPOTLIGHT_CONFIG="/System/Volumes/Data/.Spotlight-V100/VolumeConfiguration.plist"
sudo plutil -extract Exclusions xml1 -o - "$SPOTLIGHT_CONFIG"

# remove an exclusion
# sudo plutil -remove Exclusions.{index} "$SPOTLIGHT_CONFIG"

