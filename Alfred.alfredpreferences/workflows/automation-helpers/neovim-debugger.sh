#!/usr/bin/env zsh
# shellcheck disable=2009

mode="$*"

if [[ "$mode" == "killall" ]]; then
	killall neovide nvim language_server_macos_x64 language_server_macos_arm
	osascript -e 'display notification "" with title "⚔️ Killed all nvim-related processes"'
elif [[ "$mode" == "signal" ]]; then
	nvim --server "/tmp/nvim_server.pipe" --remote-send "<cmd>echo 'ping'<CR>"
elif [[ "$mode" == "report" ]]; then
	# send to alfred large type
	ps cAo 'pid,ppid,state,rss=MEM,command' | grep -E "COMMAND|neovide|nvim|language.server|rome$|node"
fi
