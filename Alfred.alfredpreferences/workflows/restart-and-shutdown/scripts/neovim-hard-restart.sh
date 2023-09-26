#!/usr/bin/env zsh
killall -9 neovide nvim language_server_macos_arm language_server_macos_x86 osascript
delay 0.5
echo "Restarting neovim."
