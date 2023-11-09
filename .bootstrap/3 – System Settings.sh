# SOURCES FOR MAC DEFAULT SETTINGS
# https://github.com/herrbischoff/awesome-macos-command-line
# https://github.com/mathiasbynens/dotfiles/blob/master/.macos
# https://macos-defaults.com/
#───────────────────────────────────────────────────────────────────────────────

sudo -v # ask for permissions upfront

# use touch-id to authenticate in the terminal
# https://sixcolors.com/post/2023/08/in-macos-sonoma-touch-id-for-sudo-can-survive-updates/
echo "auth       sufficient     pam_tid.so" | sudo tee /etc/pam.d/sudo_local

#───────────────────────────────────────────────────────────────────────────────
# SYSTEM PREFS

# Cloudflare
dns_address_1="1.1.1.1"
dns_address_2="1.0.0.1"

# set DNS on every network
networksetup -listallnetworkservices |
	sed '1d' | 
	tr -d "*" | # remove "*" marking disabled services
	xargs -I {} networksetup -setdnsservers {} "$dns_address_1" "$dns_address_2"

#───────────────────────────────────────────────────────────────────────────────
# FINDER

# Set the default location for new Finder windows
defaults write com.apple.finder NewWindowTarget 'PfHm'
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Library/Mobile%20Documents/com~apple~CloudDocs/File%20Hub"

# other settings
defaults write com.apple.finder FXEnableExtensionChangeWarning -int 0
defaults write com.apple.finder WarnOnEmptyTrash -int 0
# defaults write com.apple.finder QuitMenuItem -bool true # make finder quittable
defaults write com.apple.finder CreateDesktop false     # disable desktop icons & make desktop unfocussable

# Automatically open a new Finder window when a volume is mounted
defaults read com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults read com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Enable snap-to-grid for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

# Increase grid spacing for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist

# Increase the size of icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist

# Show item info near icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist

# Views
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1 # bigger icons
defaults write com.apple.finder _FXShowPosixPathInTitle -bool false
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv" # List view as default
chflags nohidden ~/Library                                          # Show the ~/Library folder

# search always current directory
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Expand the following File Info panes:
# “General”, “Open with”, and “Sharing & Permissions”
defaults write com.apple.finder FXInfoPanesExpanded -dict \
	General -bool true \
	OpenWith -bool true \
	Privileges -bool false
killall Finder

#───────────────────────────────────────────────────────────────────────────────

# Reduce Transparency (native mac apps & menubar)
defaults write com.apple.universalaccess reduceTransparency -bool true
killall Finder

# these three need restart
# mouse speed: 3 = max speed from System Preferences
# https://mac-os-key-repeat.vercel.app/
defaults write -g com.apple.mouse.scaling 4.0
defaults write -g InitialKeyRepeat -int 10 # normal minimum: 15 (225ms)
defaults write -g KeyRepeat -int 2         # normal minimum: 2 (30ms)
# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
defaults write NSGlobalDomain AppleShowScrollBars -string "Automatic" # when to show scrollbars
defaults write -g AppleShowAllExtensions -bool true

# save menu settings
defaults write -g NSNavPanelExpandedStateForSaveMode -bool true
defaults write -g NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write -g NSDocumentSaveNewDocumentsToCloud -bool false
defaults write NSGlobalDomain com.apple.springing.enabled -bool true
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSWindowResizeTime 0.1
# Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Printer
# expand print menu by default
defaults write -g PMPrintingExpandedStateForPrint -bool true
defaults write -g PMPrintingExpandedStateForPrint2 -bool true

defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Show language menu in the top right corner of the boot screen
sudo defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool true

# turn on firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

# Screensaver Settings
defaults -currentHost write com.apple.screensaver showClock -int 0

# screenshots
defaults write com.apple.screencapture disable-shadow -bool false
defaults write com.apple.screencapture location -string "$WD"
defaults write com.apple.screencapture type -string "png"
killall SystemUIServer

# Quicker Window Resizing
defaults -currentHost write -g NSWindowResizeTime -float 0.05

# App Store Update freq
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 2
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1 # Download newly available updates in background
defaults write com.apple.commerce AutoUpdate -bool true          # Turn on app auto-update

defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true # Prevent Photos from opening automatically when devices are plugged in
defaults write com.apple.CrashReporter DialogType -string "none"             # Disable the crash reporter
defaults write com.apple.helpviewer DevMode -bool true                       # Set Help Viewer windows to non-floating mode

# Energy Saver Settings
sudo pmset displaysleep 30 # minutes till display sleep
sudo pmset sleep 1         # will sleep when displays are off
sudo pmset autorestart 0   # restart on power failure
sudo pmset womp 1          # Wake for network access

# do not save GPG key in the keychains
defaults write org.gpgtools.common DisableKeychain -bool yes

#───────────────────────────────────────────────────────────────────────────────
# DOCK
# INFO Dock settings do not need to be saved, since the Dock-Switcher setup also
# saves them, and therefore syncs them across devices already as soon as
# Hammerspoon is up. Lines here are only kept for reference.
# defaults write com.apple.dock minimize-to-application -int 1

# HOT CORNERS
# defaults write com.apple.dock wvous-tr-corner -int 12 Top right → Notification Center
# defaults write com.apple.dock wvous-br-corner -int 0
# defaults write com.apple.dock wvous-tl-corner -int 0
# defaults write com.apple.dock wvous-bl-corner -int 0
# killall Dock

#───────────────────────────────────────────────────────────────────────────────
# TIME MACHINE

# Prevent Time Machine from prompting to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
sudo tmutil disable # disable automatic backups

#───────────────────────────────────────────────────────────────────────────────
# SAFARI
defaults write com.apple.Safari IncludeDevelopMenu -bool true            # Enable Develop menu & Inspector
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true # full URL in address bar
defaults write com.apple.Safari HomePage -string "about:blank"           # faster loading
defaults write com.apple.Safari DownloadsPath -string "$WD"              # Download path

#───────────────────────────────────────────────────────────────────────────────
# APP STORE
defaults write com.apple.appstore InAppReviewEnabled -bool false
