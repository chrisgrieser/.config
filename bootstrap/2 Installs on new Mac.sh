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

# Uninstall unneeded Mac Default apps
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

# Gems & Pip
sudo gem install anystyle-cli
pip3 install pdfannots

# Searchlink
curl -sL "https://github.com/ttscoff/searchlink/releases/latest/download/searchlink.zip" >searchlink.zip
unzip searchlink.zip
mv "./SearchLink Services/SearchLink.workflow" "$HOME/Library/Services/SearchLink.workflow"
rm -r "./Searchlink Services" searchlink.zip

#───────────────────────────────────────────────────────────────────────────────
# SETTINGS

# sketchybar
brew services start felixkratz/formulae/sketchybar

# Steam UI zoomed https://tp69.blog/2020/02/11/how-to-zoom-the-steam-client/
steamDataPath="$HOME/Library/Application Support/Steam/Steam.AppBundle/Steam/Contents/MacOS"
newSkinPath="$steamDataPath/skins/Bigger UI"
mkdir -p "$newSkinPath/resource/styles/"
cp "$steamDataPath/resource/styles/steam.styles" "$newSkinPath/resource/styles/"
echo ':root { zoom: "1.5"; }' >"$newSkinPath/resource/webkit.css"
