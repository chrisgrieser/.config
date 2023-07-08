#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

app="$*"

case "$app" in
"AltTab")
	killall "$app"
	while pgrep -xq "$app"; do sleep 0.1; done
	open -a "$app"
	;;
"svim" | "sketchybar")
	brew services restart "$app"
	;;
esac

echo -n "Restarted $app" # Alfred notification
