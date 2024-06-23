# location of the zsh configuration
export ZDOTDIR="$HOME/.config/zsh"
#───────────────────────────────────────────────────────────────────────────────

export DATA_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder"

# shellcheck disable=1091
[[ -f "$DATA_DIR/private dotfiles/api-keys.sh" ]] && source "$DATA_DIR/private dotfiles/api-keys.sh"
export EDITOR="nvim"

# workaround since pandoc does not allow default data-dirs
function pandoc() { command pandoc --data-dir="$HOME/.config/pandoc" "$@"; }

# `pass` config set here to be accessible in the Terminal as well as Alfred
export PASSWORD_STORE_CLIP_TIME=60
export PASSWORD_STORE_GENERATED_LENGTH=32
export PASSWORD_STORE_CHARACTER_SET_NO_SYMBOLS="[:alnum:]"
