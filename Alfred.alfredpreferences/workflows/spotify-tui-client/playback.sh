#!/usr/bin/env zsh
# shellcheck disable=SC2086,SC2154

playback_cmd=$1
case $playback_cmd in
"play-pause")
	spotify_player playback --play-pause
	;;
"three")
	echo "bar"
	;;
*)
	echo "default"
	;;
esac
[[ $1 == "play" ]] && shuffle="--shuffle"
notification=$(spt playback --$playback_cmd $shuffle --format="$format" 2>&1)

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
