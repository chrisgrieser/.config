#!/usr/bin/env zsh

# cannot use JXA to get browser URL, since sometimes a PWA is frontmost

source "$HOME/.zshenv" # get BROWSER_APP env var

url=$(osascript -e "tell application \"$BROWSER_APP\" 
	return URL of active tab of front window
end tell")

echo -n "$url"

