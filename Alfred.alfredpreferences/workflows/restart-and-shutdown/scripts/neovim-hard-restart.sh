#!/usr/bin/env zsh

killall -9 neovide nvim language_server_macos_arm language_server_macos_x86 osascript efm-langserver

osascript -e 'display notification "" with title "⚔️ Killed nvim & neovide processes."'
sleep 0.6
osascript -e 'tell application "Neovide" to activate' # "open -a" does not focus Neovide
