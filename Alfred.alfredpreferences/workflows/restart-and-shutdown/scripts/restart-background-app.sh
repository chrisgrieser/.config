#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

app="$*"

case "$app" in
"sketchybar reload")
	sketchybar --reload
	echo -n "🔁 Reloaded sketchybar" # Alfred notification
	return 0
	;;
"sketchybar")
	brew services restart "$app"
	;;
"AltTab" | "Hammerspoon")
	killall "$app"
	while pgrep -xq "$app"; do sleep 0.1; done
	open -a "$app"
	;;
"espanso")
	espanso restart || open -a "Espanso"
	;;
esac

echo -n "🔁 Restarted $app" # Alfred notification
