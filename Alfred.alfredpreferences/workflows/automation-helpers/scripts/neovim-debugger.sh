#!/usr/bin/env zsh

mode="$*"

if [[ "$mode" == "killall" ]]; then
	killall neovide nvim language_server_macos_arm language_server_macos_x86 osascript
	osascript -e 'display notification "" with title "⚔️ Killed nvim & neovide processes."'
elif [[ "$mode" == "report" ]]; then
	# shellcheck disable=2009
	processes="$(ps cAo 'pid,ppid,state,rss=MEM,command' |
		grep -E "COMMAND|osascript|neovide|nvim|language.server|rome$|node" | 
		sed '/^$/d')"
	if [[ $(echo -n "$processes" | wc -l) -gt 1 ]]; then
		echo -n "$processes" # send to alfred large type
	else
		osascript -e 'display notification "" with title "⚔️ No nvim processes found."'
	fi
fi
