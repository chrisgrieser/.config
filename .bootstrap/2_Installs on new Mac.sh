#!/usr/bin/env zsh
sudo -v

# BUG MAS sign in broken https://github.com/mas-cli/mas#mas-signin
# ➞ sign in manually to start download
open '/System/Applications/App Store.app'

brew bundle install --no-quarantine --verbose --no-lock \
	--file "$HOME/.config/.installed-apps-and-packages/Brewfile_iMac Home.txt"

brew services start felixkratz/formulae/sketchybar
