#!/usr/bin/env zsh
# this script assumes Homebrew is already installed
#───────────────────────────────────────────────────────────────────────────────

# INSTALLS
sudo -v

# Uninstall unneeded macOS default apps
open -a "Appcleaner" \
	"/Applications/Numbers.app" \
	"/Applications/Pages.app/" \
	"/Applications/Keynote.app" \
	"/Applications/GarageBand.app" \
	"/Applications/iMovie.app"

# Change Settings manually
open -a "Archive Utility"
osascript -e '
	tell application "System Events" to tell process "Archive Utility"
		set frontmost to true
		click menu item "Settings…" of menu "Archive Utility" of menu bar 1
	end tell'

# BUG MAS sign in currently broken due https://github.com/mas-cli/mas#-sign-in
# ➞ sign in manually to start download
open '/System/Applications/App Store.app'

# shellcheck disable=SC2034
brew bundle install --no-quarantine --verbose --no-lock --file "$HOME/Desktop/Brewfile"
brew services start felixkratz/formulae/sketchybar

# NPM
# shellcheck disable=SC2002
cat "$HOME/Desktop/NPMfile" | xargs npm install --location=global --force
npm list --location=global
