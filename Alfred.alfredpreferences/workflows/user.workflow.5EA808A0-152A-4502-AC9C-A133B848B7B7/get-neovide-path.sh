#!/usr/bin/env zsh
pgrep "neovide" &> /dev/null || return

win_title=$(osascript -e 'tell application "System Events" to tell process "neovide" to return name of front window')
full_path=${win_title//% \[*\]/} # requires: vim.opt.titlestring='%{expand(\"%:p\")} [%{mode()}]'
echo -n "$full_path"
