export ZDOTDIR="$HOME/.config/zsh" # location of this zsh configuration
export EDITOR='nvim'

#───────────────────────────────────────────────────────────────────────────────

# PANDOC
# does not have an environment var for this, so using `--data-dir` alias
alias pandoc='pandoc --data-dir="$HOME/.config/pandoc"'

# PASS
export PASSWORD_STORE_CLIP_TIME=60
export PASSWORD_STORE_GENERATED_LENGTH=30       # some services break with longer passwords m(
export PASSWORD_STORE_CHARACTER_SET="[:alnum:]" # many services break with special chars m(
alias pass="env NO_PLUGINS=true pass"           # disable plugins in `nvim` when using `pass`

# GITHUB_TOKEN
# https://github.com/settings/tokens
# For security reasons, only export token for the processes that actually need it.
# shellcheck disable=2154
if [[ "$alfred_workflow_name" == "GitFred" ]]; then
	GITHUB_TOKEN="$(cat "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles/github-token.txt")"
	export GITHUB_TOKEN
fi
