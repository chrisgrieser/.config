# INFO manually add to ensure ignorance by Spotlight

function revealIfExistent() { [[ -e "$1" ]] && open -R "$1"; }

revealIfExistent "/Applications/Cisco"
revealIfExistent "/Applications/Utilities"
revealIfExistent "$DATA_DIR/vim-data"
revealIfExistent "$HOME/Library/Mobile Documents/com~apple~CloudDocs/PDFs"

# open spotlight settings
open "x-apple.systempreferences:com.apple.preference.speech"
