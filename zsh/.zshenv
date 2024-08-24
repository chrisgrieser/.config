# shellcheck disable=1091
#───────────────────────────────────────────────────────────────────────────────

export ZDOTDIR="$HOME/.config/zsh" # location of the zsh configuration

export DATA_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder"
[[ -f "$DATA_DIR/private dotfiles/api-keys.sh" ]] && source "$DATA_DIR/private dotfiles/api-keys.sh"

# `pass` config set here to be accessible in the Terminal as well as Alfred
export PASSWORD_STORE_CLIP_TIME=60
export PASSWORD_STORE_GENERATED_LENGTH=32
export PASSWORD_STORE_CHARACTER_SET_NO_SYMBOLS="[:alnum:]"

# pandoc does not have an environment var for this, so using `--data-dir` alias
alias pandoc='pandoc --data-dir="$HOME/.config/pandoc"'
