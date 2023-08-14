#!/usr/bin/env zsh

app="$*"

case "$app" in
"AltTab"|"Hammerspoon")
	killall "$app"
	while pgrep -xq "$app"; do sleep 0.1; done
	open -a "$app"
	;;
"svim" | "sketchybar")
	brew services restart "$app"
	;;
"Espanso")
	espanso restart
	;;
esac

echo -n "🔁 Restarted $app" # Alfred notification
