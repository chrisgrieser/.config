#!/usr/bin/env zsh
# shellcheck disable=2154

pid="$*"
name=$(ps -p "$*" -co 'command=')

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
	kill -- "$pid" && msg="Killed" || msg="Could not kill"
elif [[ "$mode" == "force kill" ]]; then
	kill -9 -- "$pid" && msg="Force killed" || msg="Could not force kill"
elif [[ "$mode" == "killall" ]]; then
	killall -- "$name" && msg="Killed all processes with name" || msg="Could not kill"
elif [[ "$mode" == "force killall" ]]; then
	killall -9 -- "$name" && msg="Force killed all processes with name" || msg="Could not kill"
elif [[ "$mode" == "copy pid" ]]; then
	echo -n "$pid" | pbcopy 
	msg="✅ Copied PID for "
fi

# for Alfred notification
echo -n "$msg \"$name\""
