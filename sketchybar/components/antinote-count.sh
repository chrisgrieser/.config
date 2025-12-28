#!/usr/bin/env zsh

sql_path="$HOME/Library/Containers/com.chabomakers.Antinote/Data/Documents/notes.sqlite3"

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

# GUARD if app-switch, only trigger on deactivation of Antinote
if [[ "$SENDER" = "front_app_switched" ]]; then
	mkdir -p "$HOME/.cache/sketchybar"
	data="$HOME/.cache/sketchybar/front_app_$NAME"
	[[ -f "$data" ]] && deactivated_app=$(< "$data")
	echo -n "$INFO" > "$data"
	[[ "$deactivated_app" != "Antinote" ]] && return 0
fi

# wait for sync of reminders
[[ "$SENDER" == "system_woke" ]] && sleep 5

#───────────────────────────────────────────────────────────────────────────────

# include open reminders yesterday for reminders carrying over
antinote_count=$(sqlite3 "$sql_path" "SELECT content FROM notes")
if [[ -z $antinote_count ]]; then
	set_empty
else
	sketchybar --set "$NAME" icon="△" label="$antinote_count" \
		background.padding_right="10" icon.padding_right="3" label.padding_right="3"
fi
