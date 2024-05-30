#!/usr/bin/env zsh

# CONFIG
list_name="Tasks"

#───────────────────────────────────────────────────────────────────────────────

# GUARD only trigger on deactivation of Reminders or BusyCal
if [[ "$SENDER" = "front_app_switched" ]]; then
	mkdir -p "$HOME/.cache/sketchybar"
	data="$HOME/.cache/sketchybar/front_app1"
	[[ -f "$data" ]] && deactivated_app=$(<"$data")
	echo -n "$INFO" >"$data"
	[[ "$deactivated_app" != "Reminders" && "$deactivated_app" != "BusyCal" ]] && return 0
fi

# GUARD
if ! command -v reminders &>/dev/null; then
	sketchybar --set "$NAME" icon=" " label="reminders-cli not found"
	return 1
fi


# wait for sync of reminders
[[ "$SENDER" == "system_woke" ]] && sleep 5

#───────────────────────────────────────────────────────────────────────────────

# include open reminders yesterday for reminders carrying over
reminders_today=$(reminders show "$list_name" --due-date="today")
reminders_yesterday=$(reminders show "$list_name" --due-date="yesterday")
reminder_count=$({
	echo "$reminders_today"
	echo "$reminders_yesterday"
} | grep --count "^\d\+: ")
if [[ $reminder_count -eq 0 ]]; then
	reminder_count=""
	icon=""
	padding=0
else
	icon=" "
	padding=3
fi
sketchybar --set "$NAME" label="$reminder_count" icon="$icon" icon.padding_right=$padding
