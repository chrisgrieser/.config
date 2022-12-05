export EDITOR=nvim
export PAGER=less

#───────────────────────────────────────────────────────────────────────────────
# DIRECTORIES
export WD="$HOME/Library/Mobile Documents/com~apple~CloudDocs/File Hub"
export DOTFILE_FOLDER="$HOME/.config"
export VAULT_PATH="$HOME/main-vault"

#───────────────────────────────────────────────────────────────────────────────
# karabiner-cli
export PATH="/Library/Application Support/org.pqrs/Karabiner-Elements/bin:$PATH"

#───────────────────────────────────────────────────────────────────────────────
# pass-cli
export PASSWORD_STORE_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/Authentification/.password-store"

#───────────────────────────────────────────────────────────────────────────────
# NEOVIM-RELATED
# Neovide https://neovide.dev/command-line-referencehtml#frame
export NEOVIDE_FRAME="buttonless"

# completions for cmp-zsh https://github.com/tamago324/cmp-zsh#configuration
[[ -d $HOME/.zsh/comp ]] && export FPATH="$HOME/.zsh/comp:$FPATH"

# so linters managed by mason are available to other apps
export PATH="$HOME/.local/share/nvim/mason/bin":$PATH

# make github functions available in nvim
# shellcheck disable=1091
source "$DOTFILE_FOLDER/zsh/git_github.zsh"
