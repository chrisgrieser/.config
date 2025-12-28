#!/usr/bin/env zsh

# CONFIG
list_name="Tasks"

#───────────────────────────────────────────────────────────────────────────────
function set_empty {
	# setting padding needed, since `drawing=false` is buggy
	sketchybar --set "$NAME" label="" icon="" \
		background.padding_right="0" icon.padding_right="0" label.padding_right="0"
}

# GUARD only when not on projector
if [[ $(system_profiler SPDisplaysDataType | grep -c Resolution) -gt 1 ]]; then
	set_empty
	return
fi

# GUARD if app-switch, only trigger on deactivation of Reminders or Calendar
if [[ "$SENDER" = "front_app_switched" ]]; then
	mkdir -p "$HOME/.cache/sketchybar"
	data="$HOME/.cache/sketchybar/front_app_$NAME"
	[[ -f "$data" ]] && deactivated_app=$(< "$data")
	echo -n "$INFO" > "$data"
	[[ "$deactivated_app" != "Reminders" && "$deactivated_app" != "Calendar" ]] && return 0
fi

# wait for sync of reminders
[[ "$SENDER" == "system_woke" ]] && sleep 5

#───────────────────────────────────────────────────────────────────────────────

reminder_count=$(swift "$HOME/.config/sketchybar/components/count-reminders.swift" "$list_name")
if [[ $reminder_count -eq 0 ]]; then
	set_empty
else
	sketchybar --set "$NAME" icon="" label="$reminder_count" \
		background.padding_right="10" icon.padding_right="3" label.padding_right="3"
fi
