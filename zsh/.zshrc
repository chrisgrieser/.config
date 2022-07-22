# shellcheck disable=SC1091

export DOTFILE_FOLDER=~/dotfiles
export WD=~"/Library/Mobile Documents/com~apple~CloudDocs/File Hub"
export VAULT_PATH=~'/Library/Mobile Documents/iCloud~md~obsidian/Documents/Main Vault'

#-------------------------------------------------------------------------------

# shellcheck disable=SC1085,SC1073,SC1009

# function zle-keymap-select () {
#     case $KEYMAP in
#     ¦   vicmd) echo -ne '\e[1 q';;      # block
#     ¦   viins|main) echo -ne '\e[5 q';; # beam
#     esac
# }
# zle -N zle-keymap-select
# zle-line-init() {
#     zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
#     echo -ne "\e[5 q"
# }
# zle -N zle-line-init
# echo -ne '\e[5 q' # Use beam shape cursor on startup.


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
