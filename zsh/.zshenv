export EDITOR=nvim
export PAGER=less

export DOTFILE_FOLDER=~/dotfiles
export WD=~"/Library/Mobile Documents/com~apple~CloudDocs/File Hub"
export VAULT_PATH=~'/Main Vault'

export NEOVIDE_FRAME="buttonless" # https://neovide.dev/command-line-referencehtml#frame

source "$DOTFILE_FOLDER/zsh/git_github.zsh" # make github functions available in other apps like nvim

#───────────────────────────────────────────────────────────────────────────────

# so linters managed by mason are still available
export PATH="$HOME/.local/share/nvim/mason/bin":$PATH

# karabiner_cli
export PATH="/Library/Application Support/org.pqrs/Karabiner-Elements/bin:$PATH"
