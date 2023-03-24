#-------------------------------------------------------------------------------
# sources for mac default settings
# https://github.com/herrbischoff/awesome-macos-command-line
# https://github.com/mathiasbynens/dotfiles/blob/master/.macos
# https://macos-defaults.com/
#-------------------------------------------------------------------------------

# ask for permissions upfront
sudo -v

#-------------------------------------------------------------------------------
# System Prefs
#-------------------------------------------------------------------------------

# Network
# pw.md generated via keychain reading before
WIFI=$(grep -i -A1 "WiFi" pw.md | tail -n1)
WIFI_NAME=$(echo "$WIFI" | cut -d" " -f1)
WIFI_PW=$(echo "$WIFI" | cut -d" " -f2)
networksetup -setairportnetwork en1 "$WIFI_NAME" "$WIFI_PW"

# Cloudflare DNS
# networksetup -setdnsservers Wi-Fi 1.1.1.1 1.0.0.1
# networksetup -setdnsservers Ethernet 1.1.1.1 1.0.0.1

# Google DNS
networksetup -setdnsservers Wi-Fi 8.8.8.8 8.8.4.4
networksetup -setdnsservers Ethernet 8.8.8.8 8.8.4.4

# -------------------------------
# Finder
# -------------------------------

# set base directory
WD="$HOME/Library/Mobile Documents/com~apple~CloudDocs/File Hub/"

# Set the default location for new Finder windows
defaults write com.apple.finder NewWindowTarget 'PfHm'
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Library/Mobile%20Documents/com~apple~CloudDocs/File%20Hub"

# other settings
defaults write com.apple.finder FXEnableExtensionChangeWarning -int 0
defaults write com.apple.finder WarnOnEmptyTrash -int 0
defaults write com.apple.finder QuitMenuItem -bool true # make finder quittable
defaults write com.apple.finder CreateDesktop false # disable desktop icons & make desktop unfocussable

# Automatically open a new Finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
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
defaults write com.apple.finder ShowStatusBar -bool false
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv" # List view as default
chflags nohidden ~/Library # Show the ~/Library folder

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

# these three need restart
# mouse speed: 3 = max speed from System Preferences
# https://mac-os-key-repeat.vercel.app/
defaults write -g com.apple.mouse.scaling 4.0
defaults write -g InitialKeyRepeat -int 13 # normal minimum: 15 (225ms)
defaults write -g KeyRepeat -int 2         # normal minimum: 2 (30ms)

defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
# when to show scrollbars
defaults write NSGlobalDomain AppleShowScrollBars -string "Automatic"
# sidebar icon size (1-3)
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
# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
# expand print menu by default
defaults write -g PMPrintingExpandedStateForPrint -bool true
defaults write -g PMPrintingExpandedStateForPrint2 -bool true

# set highlight color
defaults write NSGlobalDomain AppleHighlightColor -string "0.968627 0.831373 1.000000 Purple"
# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Show language menu in the top right corner of the boot screen
sudo defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool true

# Printer setting
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# turn on firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

# Screensaver Settings
defaults -currentHost write com.apple.screensaver showClock -int 0

# screenshots
defaults write com.apple.screencapture disable-shadow -bool false
defaults write com.apple.screencapture location -string "$WD"
defaults write com.apple.screencapture type -string "png"
killall SystemUIServer

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

# Hot corners
#-------------------------------------------
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center
# 13: Lock Screen
# 14: Quick Notes

# Top right → Notification Center
defaults write com.apple.dock wvous-tr-corner -int 12

killall Dock

# Time Machine
#----------------
# Prevent Time Machine from prompting to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
sudo tmutil disable # disable automatic backups

# Safari
#--------------------------------------
defaults write com.apple.Safari IncludeDevelopMenu -bool true # Enable Develop menu and Web Inspector
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true # full URL in address bar
defaults write com.apple.Safari HomePage -string "about:blank" # faster loading
defaults write com.apple.Safari DownloadsPath -string "$WD" # Download path
