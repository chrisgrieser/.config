#!/usr/bin/env zsh

export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
app="$1"

#-SPECIAL CASES-----------------------------------------------------------------
if [[ "$app" == "sketchybar" ]]; then
	sketchybar --reload
	echo -n "🔁 Reloading $app" # Alfred notification
	return
elif [[ "$app" == "hammerspoon_reload" ]]; then
	open -g "hammerspoon://hs-reload"
	echo -n "🔁 Reloading Hammerspoon"
	return
elif [[ "$app" == "espanso" ]]; then
	espanso restart || open -a "Espanso"
	echo -n "❗ Restarted espanso"
	return
fi

#-GENERIC CASES-----------------------------------------------------------------
[[ "$app" == "front_app" ]] && app=$(osascript -e 'tell application "System Events" to return name of first process whose frontmost is true')
if [[ "$app" == "neovide" ]]; then
	echo -n "⚠ Alfred failed detecting neovide as front app."
	return 1
fi

killall "$app"

# wait
i=0
while pgrep -xq "$app"; do
	i=$((i + 1))
	sleep 0.1
	if [[ $i -gt 20 ]]; then
		echo -n "⚠️ Could not quit $app" # Alfred notification
		return 1
	fi
done
sleep 0.1

# restart
[[ "$app" == "wezterm-gui" ]] && app="WezTerm" # process name differs from app name
open -a "$app"
echo -n "❗ Restarted $app" # Alfred notification
