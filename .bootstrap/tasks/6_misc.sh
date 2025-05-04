#!/usr/bin/env zsh
set -e
#───────────────────────────────────────────────────────────────────────────────

# plist preferences
backup_path="$HOME/.config/.bootstrap/.plist/"
if [[ ! -d "$backup_path" ]]; then
	print "\e[0;33mplist backup directory not found: $backup_path\e[0m"
	return 1
fi

for plist in "$backup_path"/*.plist; do
	name="$(basename "$plist" .plist)"
	defaults import "$name" "$backup_path/$name.plist"
done

#───────────────────────────────────────────────────────────────────────────────
# Default File Openers
[[ -x "$(command -v infat)" ]] || brew install infat
echo
infat --config="$HOME/.config/.bootstrap/infat-config.toml"

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

#───────────────────────────────────────────────────────────────────────────────

# Uninstall unneeded macOS default apps
cd "/Applications" || return 1
open -a "Appcleaner" \
	"Numbers.app" "Pages.app" "Keynote.app" "GarageBand.app" "iMovie.app"
