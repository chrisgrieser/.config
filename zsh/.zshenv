# defines location of the rest of the zsh config
export ZDOTDIR="$HOME/.config/zsh"

#───────────────────────────────────────────────────────────────────────────────

# Directories
export VAULT_PATH="$HOME/main-vault"
export PASSWORD_STORE_DIR="$HOME/.password-store" # default value, but still needed for bkp script
export WD="$HOME/Library/Mobile Documents/com~apple~CloudDocs/File Hub"
export DATA_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder"
export LOCAL_REPOS="$HOME/Repos"

#───────────────────────────────────────────────────────────────────────────────
# APPS
export EDITOR=nvim

# for my configs
export BROWSER_DEFAULTS_PATH="BraveSoftware/Brave-Browser"
export BROWSER_APP="Brave Browser" # not using "$BROWSER" since it's a reserved variable
export MAIL_APP="Mimestream"
export TICKER_APP="Ivory"

#───────────────────────────────────────────────────────────────────────────────
# Save API keys outside the dotfile repo
# shellcheck disable=1091
[[ -f "$DATA_DIR/private dotfiles/api-keys.sh" ]] && source "$DATA_DIR/private dotfiles/api-keys.sh"

#───────────────────────────────────────────────────────────────────────────────

# NEOVIM
# so linters managed by mason are generally available
export PATH="$HOME/.local/share/nvim/mason/bin":$PATH

# JUPYTER
# https://docs.jupyter.org/en/latest/use/jupyter-directories.html#configuration-files
# https://jupyterlab.readthedocs.io/en/stable/user/directories.html#jupyterlab-user-settings-directory
export JUPYTER_CONFIG_DIR="$HOME/.config/jupyter"
export IPYTHONDIR="$HOME/.config/ipython"

# PANDOC
# HACK since pandoc does not allow default data-dirs
function pandoc() { command pandoc --data-dir="$HOME/.config/pandoc" "$@"; }

#───────────────────────────────────────────────────────────────────────────────

# PASS
export PASSWORD_STORE_CLIP_TIME=60
export PASSWORD_STORE_GENERATED_LENGTH=32
export PASSWORD_STORE_ENABLE_EXTENSIONS=false
export PASSWORD_STORE_CHARACTER_SET_NO_SYMBOLS="[:alnum:]"
