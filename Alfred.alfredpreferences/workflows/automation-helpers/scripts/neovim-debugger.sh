#!/usr/bin/env zsh

mode="$*"

if [[ "$mode" == "killall" ]]; then
	killall neovide nvim
	osascript -e 'display notification "" with title "⚔️ Killed nvim & neovide processes."'
elif [[ "$mode" == "signal" ]]; then
	nvim --server "/tmp/nvim_server.pipe" --remote-send "<cmd>echo 'ping'<CR>"
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
