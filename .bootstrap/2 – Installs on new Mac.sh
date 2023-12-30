# INSTALLS
sudo -v

# Uninstall unneeded macOS default apps
cd "/Applications" || return 1
open -a "Appcleaner" "Numbers.app" "Pages.app" "Keynote.app" \
	"GarageBand.app" "iMovie.app"

# Change Settings manually
open -a "Archive Utility"
osascript -e '
	tell application "System Events" to tell process "Archive Utility"
		set frontmost to true
		click menu item "Settings…" of menu "Archive Utility" of menu bar 1
	end tell'

# BUG MAS sign in broken https://github.com/mas-cli/mas#-sign-in
# ➞ sign in manually to start download
open '/System/Applications/App Store.app'

brew bundle install --no-quarantine --verbose --no-lock --file "$HOME/Desktop/Brewfile"
brew services start felixkratz/formulae/sketchybar
