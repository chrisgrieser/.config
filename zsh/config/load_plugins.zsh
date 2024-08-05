# shellcheck disable=SC1091
#───────────────────────────────────────────────────────────────────────────────

# load various completions of clis installed via homebrew
# needs to be run *before* compinit
export FPATH="$ZDOTDIR/completions:$HOMEBREW_PREFIX/share/zsh/site-functions:$FPATH"

# also loads compinit stuff, therefore has to be loaded before most plugins
source "$HOMEBREW_PREFIX/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh"

# INFO not needed when using zsh-autocomplete
# autoload compinit -Uz +X && compinit
# [[ $(uname -p) == "i386" ]] && compaudit | xargs chmod g-w # FIX for Intel Mac, https://github.com/zsh-users/zsh-completions/issues/433#issuecomment-629539004

#───────────────────────────────────────────────────────────────────────────────

source "$HOMEBREW_PREFIX/share/zsh-autopair/autopair.zsh"
source "$HOMEBREW_PREFIX/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# must be loaded *after* zsh-syntax-highlighting
source "$HOMEBREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

#───────────────────────────────────────────────────────────────────────────────

# https://github.com/wez/wezterm/blob/main/assets/shell-integration/wezterm.sh
[[ "$TERM_PROGRAM" == "WezTerm" ]] && source "$ZDOTDIR/plugins/wezterm_semantic_prompts.zsh"
source "$ZDOTDIR/plugins/magic_dashboard.zsh"

eval "$(starship init zsh)"
