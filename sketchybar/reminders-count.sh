#!/usr/bin/env zsh

# GUARD only trigger on deactivation of of GoodTask/Reminders, if only one display
if [[ "$SENDER" = "front_app_switched" ]]; then
	data="/tmp/sketchybar_front_app1"
	[[ -f "$data" ]] && deactivated_app=$(<"$data")
	echo -n "$INFO" >"$data"
	[[ "$deactivated_app" != "GoodTask" ]] && return 0
fi
[[ $(system_profiler SPDisplaysDataType | grep -c "Resolution:") -eq 2 ]] && return 0

# wait for sync of reminders
[[ "$SENDER" == "system_woke" ]] && sleep 5

# GUARD
if ! command -v reminders &>/dev/null; then
	sketchybar --set "$NAME" icon=" " label="reminders-cli not found"
	return 1
fi

#───────────────────────────────────────────────────────────────────────────────

remindersToday=$(reminders show Default --due-date="$(date +"%Y-%m-%d")" | grep -c "^\d\+: ")
if [[ $remindersToday -eq 0 ]]; then
	remindersToday=""
	icon=""
	padding=0
else
	icon=" "
	padding=3
fi
sketchybar --set "$NAME" label="$remindersToday" icon="$icon" icon.padding_right=$padding

#───────────────────────────────────────────────────────────────────────────────
sleep 1

# kill Reminders if it's not frontmost (prevents quitting reminders when using it)
front_app=$(osascript -e 'tell application "System Events" to return (name of first process where it is frontmost)')
[[ "$front_app" != "Reminders" ]] && killall "Reminders"
