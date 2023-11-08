# shellcheck disable=SC1090,SC1091,SC2292

# Completions for Homebrew https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh
# REQUIRED must be loaded before completion setup
FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

#───────────────────────────────────────────────────────────────────────────────
# INFO deactivated when using zsh-autocomplete
# # activate completions, also needed for ZSH auto suggestions & completions
# # must be loaded before plugins
# autoload compinit -Uz +X && compinit
#
# # Fix for Intel Mac, https://github.com/zsh-users/zsh-completions/issues/433#issuecomment-629539004
# [[ $(uname -p) == "i386" ]] && compaudit | xargs chmod g-w

#───────────────────────────────────────────────────────────────────────────────

function safe_source() {
	if [[ -f "$1" ]]; then
		source "$1"
	else
		echo "$1 cannot be found, skipping."
	fi
}

safe_source "$(brew --prefix)/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh"

# "fzf-tab needs to be loaded after compinit, but before plugins which will wrap
# widgets, such as zsh-autosuggestions or fast-syntax-highlighting"
# safe_source "$ZDOTDIR/plugins/fzf-tab/fzf-tab.plugin.zsh"
# safe_source "$ZDOTDIR/fzf-tab_and_completion_settings.zsh"

# INFO `brew --prefix` ensures the right path is inserted on M1 as well as  non-M1 macs
safe_source "$(brew --prefix)/share/zsh-you-should-use/you-should-use.plugin.zsh"
safe_source "$(brew --prefix)/share/zsh-autopair/autopair.zsh"
safe_source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
safe_source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# has to be loaded *after* zsh syntax highlighting
safe_source "$(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh"

safe_source "$ZDOTDIR/plugins/magic_dashboard.zsh"
#───────────────────────────────────────────────────────────────────────────────

# PROMPT
eval "$(starship init zsh)"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
