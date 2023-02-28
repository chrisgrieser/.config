#!/usr/bin/env zsh
# shellcheck disable=SC2086,SC2154
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

# run in subshell to avoid output, only pass if for notification
notification=$(spt playback --$1 --format="$format" 2>&1)
# shellcheck disable=SC2181
if [[ "$?" != "0" ]] ; then
	echo -n "$notification"
	exit 1
elif [[ -z "$notification" ]] ; then
	echo -n "⛔️ Unknown Error"
	exit 1
fi

# if shuffle isn't active, activate it
flags=$(spt playback --status --format=%f)
[[ ! "$flags" =~ "🔀" ]] && spt playback --shuffle

# if not paused, then show notification
current_status="$(spt playback --status --format=%s)"
[[ "$current_status" != "⏸" ]] && echo -n "$notification"
