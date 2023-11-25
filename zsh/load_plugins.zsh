# shellcheck disable=SC1091
#───────────────────────────────────────────────────────────────────────────────

# load various completions of clis installed via homebrew
# needs to be run before compinit
FPATH="$HOMEBREW_PREFIX/share/zsh/site-functions:${FPATH}"

# also loads compinit stuff, therefore has to be loaded before most plugins
source "$HOMEBREW_PREFIX/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh"

#───────────────────────────────────────────────────────────────────────────────

source "$HOMEBREW_PREFIX/share/zsh-you-should-use/you-should-use.plugin.zsh"
source "$HOMEBREW_PREFIX/share/zsh-autopair/autopair.zsh"
source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# has to be loaded *after* zsh syntax highlighting
source "$HOMEBREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh"

#───────────────────────────────────────────────────────────────────────────────

source "$ZDOTDIR/plugins/magic_dashboard.zsh"

eval "$(starship init zsh)"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
