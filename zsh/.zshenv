# shellcheck disable=1091
#───────────────────────────────────────────────────────────────────────────────

export ZDOTDIR="$HOME/.config/zsh" # location of the zsh configuration

private_dots="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles"
[[ -f "$private_dots/api-keys.txt" ]] && source "$private_dots/api-keys.txt"

export EDITOR='nvim'

#───────────────────────────────────────────────────────────────────────────────

# PANDOC 
# does not have an environment var for this, so using `--data-dir` alias
alias pandoc='pandoc --data-dir="$HOME/.config/pandoc"'

# PASS
# config set here to be accessible in the Terminal as well as Alfred
export PASSWORD_STORE_CLIP_TIME=60
export PASSWORD_STORE_GENERATED_LENGTH=30 # some services break with longer passwords m(
export PASSWORD_STORE_CHARACTER_SET="[:alnum:]" # many services break with special chars m(
alias pass="env NO_PLUGINS=true pass" # disable plugins in `nvim` when using `pass`

# NPM / NODE
# do not crowd `$HOME` (set in .zshenv, so it's also applied to Neovide)
export npm_config_cache="$HOME/.cache/npm"

# PENDING 23.4.0 https://github.com/debug-js/debug/issues/975#issuecomment-2532606363
export NODE_OPTIONS="--disable-warning=ExperimentalWarning"
