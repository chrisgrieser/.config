export EDITOR=nvim
export PAGER=less

#───────────────────────────────────────────────────────────────────────────────
# DIRECTORIES
export WD="$HOME/Library/Mobile Documents/com~apple~CloudDocs/File Hub"
export DOTFILE_FOLDER="$HOME/.config"
export VAULT_PATH="$HOME/main-vault"
export ICLOUD="$HOME/Library/Mobile Documents/com~apple~CloudDocs/"

#───────────────────────────────────────────────────────────────────────────────

# Pass Config
export PASSWORD_STORE_CLIP_TIME=60
export PASSWORD_STORE_GENERATED_LENGTH=32
export PASSWORD_STORE_ENABLE_EXTENSIONS=false
export PASSWORD_STORE_CHARACTER_SET_NO_SYMBOLS="[:alnum:]"

#───────────────────────────────────────────────────────────────────────────────
# NEOVIM-RELATED
# Neovide https://neovide.dev/command-line-referencehtml#frame
export NEOVIDE_FRAME="buttonless"

# completions for cmp-zsh https://github.com/tamago324/cmp-zsh#configuration
[[ -d $HOME/.zsh/comp ]] && export FPATH="$HOME/.zsh/comp:$FPATH"

# so linters managed by mason are available to other apps
export PATH="$HOME/.local/share/nvim/mason/bin":$PATH

#───────────────────────────────────────────────────────────────────────────────
# karabiner-cli
export PATH="/Library/Application Support/org.pqrs/Karabiner-Elements/bin:$PATH"

