# vim: filetype=sh

# LOCATION OF THE ZSH CONFIGURATION
export ZDOTDIR="$HOME/.config/zsh"

# DIRECTORIES
export WD="$HOME/Library/Mobile Documents/com~apple~CloudDocs/File Hub"
export DATA_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder"

# API KEYS 
# (saved outside the dotfile repo)
# shellcheck disable=1091
[[ -f "$DATA_DIR/private dotfiles/api-keys.sh" ]] && source "$DATA_DIR/private dotfiles/api-keys.sh"

# NEOVIM
export PATH="$HOME/.local/share/nvim/mason/bin":$PATH # so packages managed by mason are generally available
export EDITOR="nvim"

# PANDOC
# (workaround since pandoc does not allow default data-dirs)
function pandoc() {
	command pandoc --data-dir="$HOME/.config/pandoc" "$@"
}

# PASS
# (set here to be accessible by the Alfred workflow `Pass`)
export PASSWORD_STORE_CLIP_TIME=60
export PASSWORD_STORE_GENERATED_LENGTH=32
export PASSWORD_STORE_CHARACTER_SET_NO_SYMBOLS="[:alnum:]"
