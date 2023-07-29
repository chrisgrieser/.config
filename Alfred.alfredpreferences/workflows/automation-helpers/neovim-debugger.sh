#!/usr/bin/env zsh
# shellcheck disable=2009

mode="$*"

if [[ "$mode" == "killall" ]]; then
	killall neovide nvim osascript language_server_macos_x64 language_server_macos_arm
	osascript -e 'display notification "" with title "⚔️ Killed all nvim-related processes."'
elif [[ "$mode" == "signal" ]]; then
	nvim --server "/tmp/nvim_server.pipe" --remote-send "<cmd>echo 'ping'<CR>"
elif [[ "$mode" == "report" ]]; then
	# send to alfred large type
	processes="$(ps cAo 'pid,ppid,state,rss=MEM,command' |
		grep -E "COMMAND|osascript|neovide|nvim|language.server|rome$|node" | 
		sed '/^$/d')"
	if [[ -n "$processes" ]]; then
		echo -n "$processes"
	else
		osascript -e 'display notification "" with title "⚔️ No nvim processes found."'
	fi
fi
