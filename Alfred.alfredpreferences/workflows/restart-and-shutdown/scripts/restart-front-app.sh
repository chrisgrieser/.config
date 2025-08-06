#!/usr/bin/env zsh

front_app=$(osascript -e 'tell application "System Events" to return name of first process whose frontmost is true')

# kill
if [[ "$front_app" == "neovide" ]]; then
	# since `cmd+q` is bound to `:wqall` in nvim, this ensures the file is saved
	osascript -e 'tell application "System Events" to keystroke "q" using {command down}'
else
	killall "$front_app"
fi

# wait
i=0
while pgrep -xq "$front_app"; do
	i=$((i + 1))
	sleep 0.1
	if [[ $i -gt 20 ]]; then
		echo -n "Could not quit $front_app" # Alfred notification
		return 1
	fi
done
sleep 0.2

# restart
[[ "$front_app" == "wezterm-gui" ]] && front_app="WezTerm"
open -a "$front_app"
