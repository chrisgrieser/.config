#!/usr/bin/env zsh

# CONFIG
list_name="Tasks"

#───────────────────────────────────────────────────────────────────────────────
function set_bar {
	icon=""
	[[ -z "$1" ]] && icon=""
	sketchybar --set "$NAME" icon="$icon" label="$1"
}

#───────────────────────────────────────────────────────────────────────────────
# GUARD only when not on projector
if [[ $(system_profiler SPDisplaysDataType | grep -c Resolution) -gt 1 ]] ; then
	sketchybar --set "$NAME" drawing=false
	return 0
fi

# GUARD if app-switch, only trigger on deactivation of Reminders or Calendar
if [[ "$SENDER" = "front_app_switched" ]]; then
	mkdir -p "$HOME/.cache/sketchybar"
	data="$HOME/.cache/sketchybar/front_app1"
	[[ -f "$data" ]] && deactivated_app=$(<"$data")
	echo -n "$INFO" >"$data"
	[[ "$deactivated_app" != "Reminders" && "$deactivated_app" != "Calendar" ]] && return 0
fi

# wait for sync of reminders
[[ "$SENDER" == "system_woke" ]] && sleep 5

#───────────────────────────────────────────────────────────────────────────────

# include open reminders yesterday for reminders carrying over
reminder_count=$(swift ./components/count-reminders.swift "$list_name")
if [[ $reminder_count -eq 0 ]]; then
	set_bar ""
else
	sketchybar --set "$NAME" icon="" label="$reminder_count"
fi
