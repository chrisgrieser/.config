export EDITOR=nvim
export PAGER=less

export DOTFILE_FOLDER=~/.config
export WD=~"/Library/Mobile Documents/com~apple~CloudDocs/File Hub"
export VAULT_PATH=~'/Main Vault'

export NEOVIDE_FRAME="buttonless" # https://neovide.dev/command-line-referencehtml#frame

# shellcheck disable=1091
source "$DOTFILE_FOLDER/zsh/git_github.zsh" # make github functions available in other apps like nvim

#───────────────────────────────────────────────────────────────────────────────

# so linters managed by mason are available to other apps
export PATH="$HOME/.local/share/nvim/mason/bin":$PATH
alias eslint='eslint_d'

# karabiner_cli
export PATH="/Library/Application Support/org.pqrs/Karabiner-Elements/bin:$PATH"
