# vim: filetype=sh

# LOCATION OF THE ZSH CONFIGURATION
export ZDOTDIR="$HOME/.config/zsh"

export DATA_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder"

# (saved outside the dotfile repo)
# shellcheck disable=1091
[[ -f "$DATA_DIR/private dotfiles/api-keys.sh" ]] && source "$DATA_DIR/private dotfiles/api-keys.sh"

export EDITOR="nvim"

# (workaround since pandoc does not allow default data-dirs)
function pandoc() { command pandoc --data-dir="$HOME/.config/pandoc" "$@"; }

export PASSWORD_STORE_CLIP_TIME=60 # (set here to be accessible by the Alfred workflow for `pass`)
export PASSWORD_STORE_GENERATED_LENGTH=32
export PASSWORD_STORE_CHARACTER_SET_NO_SYMBOLS="[:alnum:]"
