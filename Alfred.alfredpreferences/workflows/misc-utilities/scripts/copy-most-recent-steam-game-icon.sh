#!/usr/bin/env zsh

# CONFIG
steam_dir="$HOME/Library/Application Support/Steam/steamapps/common/"
game_dir="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Apps/Games/"

#-------------------------------------------------------------------------------

icon=$(find "$steam_dir" -path "*.app/Contents/Resources/*.icns" -mmin -60 | head -n1)
if [[ ! -f "$icon" ]] ; then
	echo "No icon found."
	exit 1
fi
game_shortcut=$(find "$game_dir" -maxdepth 1 -name "*.app" -mmin -60 | head -n1)
if [[ ! -d "$game_shortcut" ]] ; then # `-d`, since `.app` are actually directories
	echo "No game shortcut found."
	exit 1
fi

#-------------------------------------------------------------------------------

# copy icon
osascript -e "tell application \"Finder\" to set the clipboard to (POSIX file \"$icon\")"

# paste icon
open -R "$game_shortcut" # reveal in Finder
sleep 0.1
osascript -e '
	tell application "System Events" 
		keystroke "i" using {command down}
		delay 0.1
		key code 48 # tab
		delay 0.1
		keystroke "v" using {command down}
	end tell
'
