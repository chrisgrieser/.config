# GENERAL
export ZDOTDIR="$HOME/.config/zsh" # location of this zsh configuration
export EDITOR='nvim'

#───────────────────────────────────────────────────────────────────────────────

# API KEYS
private_dots="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles"
# shellcheck disable=1091
[[ -f "$private_dots/api-keys.txt" ]] && source "$private_dots/api-keys.txt"

# https://github.com/settings/tokens
# needed permissions:
# - notifications (Alfred workflow & Sketchybar)
# - deleting repos (`delete_forks_with_no_open_prs`)
# - repos (forking, creating, etc.)
GITHUB_TOKEN="$(cat "$private_dots/github-token.txt")"
export GITHUB_TOKEN

# PANDOC
# does not have an environment var for this, so using `--data-dir` alias
alias pandoc='pandoc --data-dir="$HOME/.config/pandoc"'

# PASS
export PASSWORD_STORE_CLIP_TIME=60
export PASSWORD_STORE_GENERATED_LENGTH=30       # some services break with longer passwords m(
export PASSWORD_STORE_CHARACTER_SET="[:alnum:]" # many services break with special chars m(
alias pass="env NO_PLUGINS=true pass"           # disable plugins in `nvim` when using `pass`
