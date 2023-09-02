#!/usr/bin/env zsh

killall neovide nvim language_server_macos_arm language_server_macos_x86 osascript
osascript -e 'display notification "" with title "⚔️ Killed nvim & neovide processes."'
sleep 0.5

# "open -a" does not focus Neovide
osascript -e 'tell application "Neovide" to activate'
