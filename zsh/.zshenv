# Apps
export EDITOR=nvim
export PAGER=less
export BROWSER="Brave Browser"

# Directories
export WD="$HOME/Library/Mobile Documents/com~apple~CloudDocs/File Hub/"
export DOTFILE_FOLDER="$HOME/.config/"
export VAULT_PATH="$HOME/main-vault/"
export ICLOUD="$HOME/Library/Mobile Documents/com~apple~CloudDocs/"
export PASSWORD_STORE_DIR="$HOME/.password-store/" # default value, but still needed for bkp script

#───────────────────────────────────────────────────────────────────────────────

# Open AI API Key stored outside of public git repo (symlinked file)
# Accessed by nvim plugins as well as shell plugins
OPENAI_API_KEY=$(tr -d "\n" < "$ICLOUD/Dotfolder/private dotfiles/openai_api_key")
export OPENAI_API_KEY

# Pass Config
export PASSWORD_STORE_CLIP_TIME=60
export PASSWORD_STORE_GENERATED_LENGTH=32
export PASSWORD_STORE_ENABLE_EXTENSIONS=false
export PASSWORD_STORE_CHARACTER_SET_NO_SYMBOLS="[:alnum:]"

# vidir
export PATH="$DOTFILE_FOLDER/zsh/plugins":$PATH

# NEOVIM: Neovide https://neovide.dev/command-line-referencehtml#frame
export NEOVIDE_FRAME="buttonless"

# NEOVIM: completions for cmp-zsh https://github.com/tamago324/cmp-zsh#configuration
[[ -d $HOME/.zsh/comp ]] && export FPATH="$HOME/.zsh/comp:$FPATH"

# NEOVIM: so linters managed by mason are available to other apps
export PATH="$HOME/.local/share/nvim/mason/bin":$PATH
