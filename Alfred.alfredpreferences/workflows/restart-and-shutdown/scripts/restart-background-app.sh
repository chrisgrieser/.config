#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

app="$*"

case "$app" in
"sketchybar")
	sketchybar --reload
	echo -n "🔁 Reloaded sketchybar" # Alfred notification
	return 0
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
