#!/usr/bin/env zsh

FRONT_APP=$(osascript -e 'tell application "System Events" to return name of first process whose frontmost is true')
if [[ "$FRONT_APP" == "neovide" ]]; then
	echo -n "Could not find frontmost app" # Alfred notification
else
	killall "$FRONT_APP"
fi


# wait for 2.0 secs
i=0
while pgrep -xq "$FRONT_APP"; do
	i=$((i + 1))
	sleep 0.1
	if [[ $i -gt 20 ]]; then
		echo -n "Could not quit $FRONT_APP" # Alfred notification
		return 1
	fi
done

#───────────────────────────────────────────────────────────────────────────────

[[ "$FRONT_APP" == "wezterm-gui" ]] && FRONT_APP="WezTerm"
sleep 0.2
open -a "$FRONT_APP"
sleep 0.2
open -a "$FRONT_APP"
