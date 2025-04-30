#!/usr/bin/env zsh
# INFO manually add to ensure ignorance by Spotlight

function revealIfExistent() { [[ -e "$1" ]] && open -R "$1"; }

revealIfExistent "/Applications/Utilities"
revealIfExistent "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/nvim-data"
revealIfExistent "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Academia/PDFs"

# open spotlight settings
open "x-apple.systempreferences:com.apple.preference.speech"
