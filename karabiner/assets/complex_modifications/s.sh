#!/usr/bin/env zsh

# FRONT_APP=$(osascript -e 'tell application "System Events" to return name of first process whose frontmost is true')
FRONT_APP="Brave Browser"
killall "$FRONT_APP"

i=0
while pgrep -xq "$FRONT_APP"; do
	i=$((i + 1))
	sleep 0.05
	if [[ "$i" -gt 30 ]]; then
		osascript -e "display notification \"\" with title \"Could not quit $FRONT_APP\""
		return 1
	fi
done

[[ "$FRONT_APP" == "wezterm-gui" ]] && FRONT_APP="WezTerm"
open -a "$FRONT_APP"
