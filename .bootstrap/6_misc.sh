#!/usr/bin/env zsh
set -e
#───────────────────────────────────────────────────────────────────────────────

# plist preferences
defaults import com.apple.notificationcenterui ~/.config/.bootstrap/plist/com.apple.notificationcenterui.plist

#───────────────────────────────────────────────────────────────────────────────
# Default File Openers (infat) https://github.com/philocalyst/infat
[[ -x "$(command -v infat)" ]] || brew install philocalyst/tap/infat
infat # without arg, applies `~/.config/infat/config.toml`
brew uninstall infat && brew untap philocalyst/tap

#───────────────────────────────────────────────────────────────────────────────

# Browser Symlinks for Alfred
browser_setting="$HOME/Library/Application Support/BraveSoftware/Brave-Browser"

my_bookmarks="$browser_setting/Default/Bookmarks"
my_localstate="$browser_setting/Local State"
chrome_bookmarks="$HOME/Library/Application Support/Google/Chrome/Default/Bookmarks"
chrome_localstate="$HOME/Library/Application Support/Google/Chrome/Local State"

mkdir -p "$(dirname "$chrome_bookmarks")"
mkdir -p "$(dirname "$chrome_localstate")"

ln -sf "$my_bookmarks" "$chrome_bookmarks"
ln -sf "$my_localstate" "$chrome_localstate"

echo "Symlinks created."
