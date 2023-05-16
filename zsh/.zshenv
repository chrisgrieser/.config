# Apps
export EDITOR=nvim
export PAGER="less -RF"

# Directories
export DOTFILE_FOLDER="$HOME/.config/"
export VAULT_PATH="$HOME/main-vault/"
export PASSWORD_STORE_DIR="$HOME/.password-store/" # default value, but still needed for bkp script
export WD="$HOME/Library/Mobile Documents/com~apple~CloudDocs/File Hub/"

export DATA_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder" 

# defines location of the rest of the zsh config
export ZDOTDIR="$DOTFILE_FOLDER/zsh"

# define default pandoc location (HACK since pandoc does not allow default data-dirs)
function pandoc () {
	command pandoc --data-dir="$DOTFILE_FOLDER/pandoc" "$@"
}

#───────────────────────────────────────────────────────────────────────────────

# OpenAI API Key stored outside of public git repo (symlinked file)
OPENAI_API_KEY=$(tr -d "\n" <"$DATA_DIR/private dotfiles/openai-api-key.txt")
export OPENAI_API_KEY

# gh-cli
GITHUB_TOKEN=$(tr -d "\n" <"$DATA_DIR/private dotfiles/github_token.txt")
export GITHUB_TOKEN

#───────────────────────────────────────────────────────────────────────────────

# NEOVIM: so linters managed by mason are available to other apps
export PATH="$HOME/.local/share/nvim/mason/bin":$PATH
