#!/usr/bin/env zsh

pid="$*"
name=$(ps -p "$*" -co 'command=')

# shellcheck disable=2154
if [[ "$mode" == "kill" ]]; then
	kill "$pid" && msg="Killed" || msg="Could not kill"
elif [[ "$mode" == "force kill" ]]; then
	kill -9 "$pid" && msg="Force Killed" || msg="Could not force kill"
elif [[ "$mode" == "killall" ]]; then
	killall "$name" && msg="Killed all processes with name" || msg="Could not kill"
elif [[ "$mode" == "restart app" ]]; then
	kill "$pid"
	# shellcheck disable=2181
	if [[ $? -ne 0 ]]; then
		msg="Could not quit."
		return 1
	fi

	while kill -0 "$pid" &>/dev/null; do sleep 0.1; done
	sleep 0.2
	open -a "$name"
fi

echo -n "$msg $name"
