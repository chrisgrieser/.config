#!/usr/bin/env zsh

if ! command -v iina &>/dev/null; then print "⚠️ iina-cli not installed." && return 1; fi

#───────────────────────────────────────────────────────────────────────────────

# cannot use JXA to get browser URL, since sometimes a PWA is frontmost
# shellcheck disable=1091
source "$HOME/.zshenv" # get BROWSER_APP env var
URL=$(osascript -e "tell application \"$BROWSER_APP\" 
	return URL of active tab of front window
end tell")

if [[ -z "$URL" ]]; then
	echo -n "❌ Tab could not be retrieved."
	return 1
fi

#───────────────────────────────────────────────────────────────────────────────

iina --no-stdin "$URL"
tell application "System Events" to tell process "IINA" 
	set frontmost to true 
	try 
		click menu item "Exit Full Screen" of menu "Video" of menu bar 1
		delay 0.4 
	end try 
	click menu item "Float on Top" of menu "Video" of menu bar 1 
end tell
