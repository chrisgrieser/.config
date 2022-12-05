# https://www.passwordstore.org/
#───────────────────────────────────────────────────────────────────────────────

# shorthands
alias pc='pass --clip'
alias p='pass'
alias pe='pass edit'
alias pf='pass find'
alias pi='pass insert --echo'

# Config
export PASSWORD_STORE_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/Authentification/.password-store"
export PASSWORD_STORE_CLIP_TIME=60
export PASSWORD_STORE_GENERATED_LENGTH=32
export PASSWORD_STORE_ENABLE_EXTENSIONS=false
export PASSWORD_STORE_CHARACTER_SET_NO_SYMBOLS="[:alnum:]"

