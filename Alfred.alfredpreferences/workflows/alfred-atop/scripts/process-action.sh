#!/usr/bin/env zsh
# shellcheck disable=2154

pid="$*"
name=$(ps -p "$*" -co "command=")

#───────────────────────────────────────────────────────────────────────────────

if [[ "$mode" == "restart app" ]]; then
	kill "$pid"
	# shellcheck disable=2181
	if [[ $? -ne 0 ]]; then
		msg="Could not quit app."
		return 1
	fi

	while kill -0 "$pid" &>/dev/null; do sleep 0.1; done
	sleep 0.2
	open -a "$name"
	return 0
fi

if [[ "$mode" == "kill" ]]; then
	kill -- "$pid" 
	msg="Killed"
elif [[ "$mode" == "force kill" ]]; then
	kill -9 -- "$pid" 
	msg="Force killed"
elif [[ "$mode" == "killall" ]]; then
	killall -- "$name" 
	msg="Killed all processes with name"
elif [[ "$mode" == "force killall" ]]; then
	killall -9 -- "$name" 
	msg="Force killed all processes with name"
elif [[ "$mode" == "copy process path" ]]; then
	process_path=$(ps -p "$pid" -o "command=")
	if [[ -z "$process_path" ]]; then
		msg="⚠️ Could not find process path."
	else
		echo -n "$process_path" | pbcopy
		msg="✅ Copied process path: \"$process_path\""
	fi
	echo -n "$msg" # Alfred notification
	return 0
fi
# shellcheck disable=2181
[[ $? -ne 0 ]] && msg="Could not $mode"

echo -n "$msg \"$name\"" # for Alfred notification
