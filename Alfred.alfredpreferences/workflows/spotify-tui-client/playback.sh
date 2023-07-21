#!/usr/bin/env zsh
# shellcheck disable=SC2086,SC2154

[[ $1 == "play" ]] && shuffle="--shuffle"
notification=$(spt playback --$1 $shuffle --format="$format" 2>&1)

# shellcheck disable=SC2181
if [[ "$?" != "0" ]]; then
	echo -n "$notification"
	exit 1
elif [[ -z "$notification" ]]; then
	echo -n "⛔️ Unknown Error"
	exit 1
fi

# if not paused, then show notification
current_status="$(spt playback --status --format=%s)"
[[ "$current_status" != "⏸" ]] && echo -n "$notification"
