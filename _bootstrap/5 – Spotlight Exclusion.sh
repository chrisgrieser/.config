#!/usr/bin/env zsh
# https://github.com/mattprice/dotfiles/blob/master/scripts/spotlight-ignore.rb

if ! sudo -nv ; then
	echo "script requires sudo rights."
	print -z "sudo -v"
	return 1
fi
#───────────────────────────────────────────────────────────────────────────────

SPOTLIGHT_CONFIG="/System/Volumes/Data/.Spotlight-V100/VolumeConfiguration.plist"

function addExclusion() {
	sudo plutil -insert Exclusions.0 -string "$1" "$SPOTLIGHT_CONFIG"
}

addExclusion "/Applications/Utilities"
addExclusion "/Applications/Cisco"
addExclusion "/Volumes/Externe A"
addExclusion "/Volumes/Externe B"
addExclusion "/Volumes/Externe C"
addExclusion "$DATA_DIR/Backups"
addExclusion "$DATA_DIR/vim-data"

#───────────────────────────────────────────────────────────────────────────────

# restart spotlight indexing (WARN this also requires writing exclusions again)
# sudo mdutil -E -i on /
# sudo rm -R "$SPOTLIGHT_CONFIG"

# show current exclusions
# SPOTLIGHT_CONFIG="/System/Volumes/Data/.Spotlight-V100/VolumeConfiguration.plist"
# sudo plutil -extract Exclusions xml1 -o - "$SPOTLIGHT_CONFIG"

# remove an exclusion
# sudo plutil -remove Exclusions.{index} "$SPOTLIGHT_CONFIG"
