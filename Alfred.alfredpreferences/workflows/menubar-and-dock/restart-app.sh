#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

app="$*"

case "$app" in
	"AltTab"|"Rocket") 
		killall "$app"
		while pgrep -q "$app"; do sleep 0.1; done
		open -a "$app"
	;;
	"svim"|"sketchybar") echo 2 or 3
		brew services restart "$app"
	;;
esac

# HACK for https://github.com/FelixKratz/SketchyBar/issues/322
sleep 2
osascript -l JavaScript "$DOTFILE_FOLDER/utility-scripts/dismiss-notification.js"
