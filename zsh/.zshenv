# vim: filetype=sh

# INFO defines location of the zsh config
export ZDOTDIR="$HOME/.config/zsh"
#───────────────────────────────────────────────────────────────────────────────

# Directories
export WD="$HOME/Library/Mobile Documents/com~apple~CloudDocs/File Hub"
export DATA_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder"
export LOCAL_REPOS="$HOME/repos"

# settings
export EDITOR="nvim"

#───────────────────────────────────────────────────────────────────────────────

# Save API keys outside the dotfile repo
# shellcheck disable=1091
[[ -f "$DATA_DIR/private dotfiles/api-keys.sh" ]] && source "$DATA_DIR/private dotfiles/api-keys.sh"

# NEOVIM
# so packages managed by mason are generally available
export PATH="$HOME/.local/share/nvim/mason/bin":$PATH

# PANDOC
# HACK since pandoc does not allow default data-dirs
function pandoc() { command pandoc --data-dir="$HOME/.config/pandoc" "$@"; }

# PASS
export PASSWORD_STORE_CLIP_TIME=60
export PASSWORD_STORE_GENERATED_LENGTH=32
export PASSWORD_STORE_CHARACTER_SET_NO_SYMBOLS="[:alnum:]"
