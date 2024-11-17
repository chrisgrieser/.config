#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
#───────────────────────────────────────────────────────────────────────────────

app="$1"

# RELOAD
if [[ "$app" == "sketchybar" ]]; then
	sketchybar --reload
	echo -n "🔁 Reloading $app" # Alfred notification
	return
fi

# RESTART
if [[ "$app" == "espanso" ]]; then
	espanso restart || open -a "Espanso"
elif [[ "$app" == "Neovide" ]]; then
	killall "Neovide"
	killall -9 "nvim"
	while pgrep -xq "nvim" || pgrep -xq "Neovide"; do sleep 0.1; done
	open -a "Neovide"
else
	killall "$app"
	while pgrep -xq "$app"; do sleep 0.1; done
	open -a "$app"
fi
echo -n "❗ Restarted $app" # Alfred notification
