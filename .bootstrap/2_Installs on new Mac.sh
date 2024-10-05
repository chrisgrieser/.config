#!/usr/bin/env zsh
# INSTALLS
sudo -v

# Uninstall unneeded macOS default apps
cd "/Applications" || return 1
open -a "Appcleaner" \
	"Numbers.app" "Pages.app" "Keynote.app" "GarageBand.app" "iMovie.app"

# BUG MAS sign in broken https://github.com/mas-cli/mas#-sign-in
# ➞ sign in manually to start download
open '/System/Applications/App Store.app'

# Homebrew & MAS
brew bundle install --no-quarantine --verbose --no-lock --file "$HOME/Desktop/Brewfile"
brew services start felixkratz/formulae/sketchybar
