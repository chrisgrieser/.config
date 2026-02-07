#!/usr/bin/env zsh
steam_dir="$HOME/Library/Application Support/Steam/steamapps/common/"
icon=$(find "$steam_dir" -path "*.app/Contents/Resources/*.icns" -mmin -60 | head -n1)
[[ -f "$icon" ]] || exit 1
osascript -e "tell application \"Finder\" to set the clipboard to (POSIX file \"$icon\")"

game_dir="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Apps/Games/"
game_shortcut=$(find "$game_dir" -maxdepth 1 -name "*.app" -mmin -60 | head -n1)
open -R "$game_shortcut" # reveal in Finder
osascript -e '
	tell application "System Events" 
		keystroke "i" using {command down}
		delay 0.1
		key code 48 # tab
		delay 0.1
		keystroke "v" using {command down}
	end tell
'
