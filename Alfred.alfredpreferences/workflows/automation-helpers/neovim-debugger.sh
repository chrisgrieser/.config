#!/usr/bin/env zsh

mode="$*"

if [[ "$mode" == "killall" ]]; then
	killall neovide nvim osascript language_server_macos_x64 language_server_macos_arm
elif [[ "$mode" == "signal" ]]; then
	nvim --server "/tmp/nvim_server.pipe" --remote-send "<cmd>echo 'ping'<CR>"
elif [[ "$mode" == "report" ]]; then

fi
