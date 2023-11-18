# shellcheck disable=SC1091
#───────────────────────────────────────────────────────────────────────────────

# must be loaded *before* zsh syntax highlighting
source "$ZDOTDIR/plugins/zsh-no-ps2/zsh-no-ps2.plugin.zsh"

# also loads compinit stuff
source "$(brew --prefix)/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh"

# INFO `brew --prefix` ensures the right path is inserted on M1 as well as non-M1 macs
source "$(brew --prefix)/share/zsh-you-should-use/you-should-use.plugin.zsh"
source "$(brew --prefix)/share/zsh-autopair/autopair.zsh"
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# has to be loaded *after* zsh syntax highlighting
source "$(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh"

source "$ZDOTDIR/plugins/magic_dashboard.zsh"

#───────────────────────────────────────────────────────────────────────────────

# PROMPT
eval "$(starship init zsh)"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
