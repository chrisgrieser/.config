# shellcheck disable=1091
#───────────────────────────────────────────────────────────────────────────────

export ZDOTDIR="$HOME/.config/zsh" # location of the zsh configuration

private_dots="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles"
[[ -f "$private_dots/api-keys.txt" ]] && source "$private_dots/api-keys.txt"

export EDITOR='nvim'

# pandoc does not have an environment var for this, so using `--data-dir` alias
alias pandoc='pandoc --data-dir="$HOME/.config/pandoc"'

#───────────────────────────────────────────────────────────────────────────────

# `pass` config set here to be accessible in the Terminal as well as Alfred
export PASSWORD_STORE_CLIP_TIME=60
export PASSWORD_STORE_GENERATED_LENGTH=30 # some services break with longer passwords m(
export PASSWORD_STORE_CHARACTER_SET="[:alnum:]" # many services break with special chars m(
alias pass="env NO_PLUGINS=true pass" # not using `nvim` with its plugins with `pass` for security

#───────────────────────────────────────────────────────────────────────────────
# NPM
# do not crowd `$HOME`. (Set in .zshenv, so it's also applied to Neovide.)
export npm_config_cache="$HOME/.cache/npm"
#───────────────────────────────────────────────────────────────────────────────

