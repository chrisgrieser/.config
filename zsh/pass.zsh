# https://www.passwordstore.org/
#───────────────────────────────────────────────────────────────────────────────

# shorthands
alias pc='pass --clip'
alias p='pass'
alias pe='pass edit'
alias pf='pass find'
alias pi='pass insert --echo'

# Config
# PASSWORD_STORE_DIR set in zshenv
export PASSWORD_STORE_CLIP_TIME=60
export PASSWORD_STORE_GENERATED_LENGTH=32
export PASSWORD_STORE_ENABLE_EXTENSIONS=false
export PASSWORD_STORE_CHARACTER_SET_NO_SYMBOLS="[:alnum:]"

