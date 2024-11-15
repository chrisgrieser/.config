#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

app="$*"

# shellcheck disable=2154
if [[ "$app" == "Hammerspoon" && "$action" == "reload" ]]; then
	open -g "hammerspoon://hs-reload"
	echo -n "🔁 Reloading Hammerspoon" # Alfred notification
	return 3
fi

case "$app" in
"sketchybar")
	sketchybar --reload
	echo -n "🔁 Reloading sketchybar" # Alfred notification
	return 0
	;;
"AltTab" | "Hammerspoon" | "Mona")
	killall "$app"
	while pgrep -xq "$app"; do sleep 0.1; done
	open -a "$app"
	echo -n "❗ Restarted $app" # Alfred notification
	;;
"espanso")
	espanso restart || open -a "Espanso"
	echo -n "❗ Restarted $app" # Alfred notification
	;;
esac
