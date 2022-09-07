#!/usr/bin/env zsh
# this script assumes Homebrew is already installed
#-------------------------------------------------------------------------------

# INSTALLS
sudo -v

sudo gem install anystyle-cli

pip3 install pdfannots
pip3 install alacritty-colorscheme

# MAS CLI sign in currently broken due to Apple API change
# Sign in Bug: https://github.com/mas-cli/mas#-sign-in
# ➞ sign in manually to start download
open '/System/Applications/App Store.app'

# shellcheck disable=SC2034
brew bundle install --no-quarantine --verbose --no-lock --file ~'/Desktop/Brewfile'

# Uninstall unneeded Mac Default apps
open -a "Appcleaner" \
    "/Applications/Numbers.app" \
    "/Applications/Pages.app/" \
    "/Applications/GarageBand.app" \
    "/Applications/Keynote.app" \
    "/Applications/iMovie.app"

# NPM https://stackoverflow.com/a/41199625
# shellcheck disable=SC2002
cat ~'/Desktop/NPMfile' | xargs npm install --location=global --force
npm list --location=global

# shellcheck disable=SC2002
cat ~'/Desktop/Pip3File' | xargs pip3 install
pip list --not-required

#-------------------------------------------------------------------------------
# SETTINGS
#-------------------------------------------------------------------------------

# Espanso
espanso service register

# sketchy
brew services start felixkratz/formulae/sketchybar
brew services start felixkratz/formulae/svim

# make Finder quittable
defaults write com.apple.finder QuitMenuItem -bool true
killall Finder

# change setting of archive utility
open "/System/Library/CoreServices/Applications/Archive Utility.app"

# Twitterific: run headless http://support.iconfactory.com/kb/twitterrific/advanced-settings-using-the-command-line-macos
defaults write com.iconfactory.Twitterrific5 advancedShowDockIcon -bool NO

# Portfolio Performance
font_size=19
c_css_location=~'/Library/Application Support/name.abuchen.portfolio.product/workspace/.metadata/.plugins/name.abuchen.portfolio.ui/'
mkdir -p "$c_css_location"
printf "%s" "{\nfont-size: ""$font_size"";\n}" >> "$c_css_location"/custom.css

# Steam UI https://tp69.blog/2020/02/11/how-to-zoom-the-steam-client/
steamDataPath=~"/Library/Application Support/Steam/Steam.AppBundle/Steam/Contents/MacOS"
newSkinPath="$steamDataPath""/skins/Bigger UI"
mkdir -p "$newSkinPath"/resource/styles/
cp "$steamDataPath"/resource/styles/steam.styles "$newSkinPath"/resource/styles/
echo ":root { zoom: \"1.5\"; }" > "$newSkinPath"/resource/webkit.css

