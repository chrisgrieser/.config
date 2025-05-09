export ZDOTDIR="$HOME/.config/zsh" # location of this zsh configuration
export EDITOR='nvim'

# PANDOC
# does not have an environment var for this, so using `--data-dir` alias
alias pandoc='pandoc --data-dir="$HOME/.config/pandoc"'

# PASS
export PASSWORD_STORE_CLIP_TIME=60
export PASSWORD_STORE_GENERATED_LENGTH=30       # some services break with longer passwords m(
export PASSWORD_STORE_CHARACTER_SET="[:alnum:]" # many services break with special chars m(
alias pass="env NO_PLUGINS=true pass"           # disable plugins in `nvim` when using `pass`

#───────────────────────────────────────────────────────────────────────────────

# API KEYS
private_dots="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles"

# https://github.com/settings/tokens
GITHUB_TOKEN="$(cat "$private_dots/github-token.txt")"
export GITHUB_TOKEN

# https://platform.openai.com/api-keys
# used for codecompanion.nvim
OPENAI_API_KEY="$(cat "$private_dots/openai-api-key.txt")"
export OPENAI_API_KEY
