sudo -v

# Install Homebrew itself
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# needed for php installation, php needed for Spotify workflow
xcode-select --install

# MAS CLI sign in currently broken due to Apple API change
# Sign in Bug: https://github.com/mas-cli/mas#-sign-in
# ➞ sign in manually to start download
open '/System/Applications/App Store.app'

# -------------
# INSTALLS
# -------------

# shellcheck disable=SC2034
HOMEBREW_CASK_OPTS="--no-quarantine"
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

# -----------
# SETTINGS
# -----------

# change setting of archive utility
open "/System/Library/CoreServices/Applications/Archive Utility.app"

# Twitterific: run headless http://support.iconfactory.com/kb/twitterrific/advanced-settings-using-the-command-line-macos
defaults write com.iconfactory.Twitterrific5 advancedShowDockIcon -bool NO

# change font size of Portfolio Performance
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

# Espanso
espanso service register
