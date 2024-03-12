# INFO manually add to ensure ignorance by Spotlight

function revealIfExistent() { [[ -e "$1" ]] && open -R "$1"; }

#───────────────────────────────────────────────────────────────────────────────

revealIfExistent "/Applications/Cisco"
revealIfExistent "/Applications/Utilities"
revealIfExistent "$DATA_DIR/vim-data"
revealIfExistent "$DATA_DIR/Backups"
revealIfExistent "/Users/chrisgrieser/Library/Mobile Documents/com~apple~CloudDocs/PDFs"

open "x-apple.systempreferences:com.apple.preference.speech"
