# shellcheck disable=SC1091

export DOTFILE_FOLDER=~/dotfiles
export WD=~"/Library/Mobile Documents/com~apple~CloudDocs/File Hub"
export VAULT_PATH=~'/Library/Mobile Documents/iCloud~md~obsidian/Documents/Main Vault'

#-------------------------------------------------------------------------------

source "$DOTFILE_FOLDER/zsh/load_plugins.zsh"
source "$DOTFILE_FOLDER/zsh/aliases.zsh"
source "$DOTFILE_FOLDER/zsh/history_config.zsh"
source "$DOTFILE_FOLDER/zsh/docs_man.zsh"
source "$DOTFILE_FOLDER/zsh/terminal_utils.zsh"
source "$DOTFILE_FOLDER/zsh/fzf_functions.zsh"
source "$DOTFILE_FOLDER/zsh/git_github.zsh"
source "$DOTFILE_FOLDER/zsh/homebrew.zsh"
source "$DOTFILE_FOLDER/zsh/npm.zsh"
source "$DOTFILE_FOLDER/zsh/keybindings.zsh"
source "$DOTFILE_FOLDER/zsh/general_and_plugin_configs.zsh"
source "$DOTFILE_FOLDER/zsh/../pandoc/pandoc.zsh"
