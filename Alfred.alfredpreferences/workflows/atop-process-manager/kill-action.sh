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
elif [[ "$mode" == "restart" ]]; then
	kill "$pid"
	while kill -0 "$pid" &>/dev/null; do sleep 0.1; done
	open -a "$name" || msg=""

	# shellcheck disable=2181
	if [[ $? -eq 0 ]]; then
		msg="Killed all processes with name"
	else
		msg="Could not kill"
	fi
fi

echo -n "$msg $name"
