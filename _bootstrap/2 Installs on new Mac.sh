#!/usr/bin/env zsh
# this script assumes Homebrew is already installed
#───────────────────────────────────────────────────────────────────────────────

# INSTALLS
sudo -v

# BUG MAS sign in currently broken due https://github.com/mas-cli/mas#-sign-in
# ➞ sign in manually to start download
open '/System/Applications/App Store.app'

# shellcheck disable=SC2034
brew bundle install --no-quarantine --verbose --no-lock --file "$HOME/Desktop/Brewfile"

# Uninstall unneeded macOS default apps
open -a "Appcleaner" \
	"/Applications/Numbers.app" \
	"/Applications/Pages.app/" \
	"/Applications/GarageBand.app" \
	"/Applications/Keynote.app" \
	"/Applications/iMovie.app"

# NPM
# shellcheck disable=SC2002
cat ~'/Desktop/NPMfile' | xargs npm install --location=global --force
npm list --location=global

#───────────────────────────────────────────────────────────────────────────────
# SETTINGS

# sketchybar
brew services start felixkratz/formulae/sketchybar
