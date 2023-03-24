# Apps
export EDITOR=nvim
export PAGER=less

# Directories
export DOTFILE_FOLDER="$HOME/.config/"
export VAULT_PATH="$HOME/main-vault/"
export PASSWORD_STORE_DIR="$HOME/.password-store/" # default value, but still needed for bkp script
export ICLOUD="$HOME/Library/Mobile Documents/com~apple~CloudDocs/"
export WD="$ICLOUD/File Hub/"
export DATA_DIR="$ICLOUD/Dotfolder" # to prevent commit spam on dotfile repo, store data in iCloud instead

# defines location of the rest of the zsh config
export ZDOTDIR="$DOTFILE_FOLDER/zsh"

#───────────────────────────────────────────────────────────────────────────────

# OpenAI API Key stored outside of public git repo (symlinked file)
OPENAI_API_KEY=$(tr -d "\n" <"$ICLOUD/Dotfolder/private dotfiles/openai-api-key.txt")
export OPENAI_API_KEY

# Pass Config
export PASSWORD_STORE_CLIP_TIME=60
export PASSWORD_STORE_GENERATED_LENGTH=32
export PASSWORD_STORE_ENABLE_EXTENSIONS=false
export PASSWORD_STORE_CHARACTER_SET_NO_SYMBOLS="[:alnum:]"

# vidir availability
export PATH="$DOTFILE_FOLDER/zsh/plugins":$PATH

# NEOVIM: so linters managed by mason are available to other apps
export PATH="$HOME/.local/share/nvim/mason/bin":$PATH
