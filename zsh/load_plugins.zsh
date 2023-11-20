# shellcheck disable=SC1091
#───────────────────────────────────────────────────────────────────────────────

# also loads compinit stuff, therefore has to be loaded before
# source "$(brew --prefix)/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh"

# activate completions, also needed for ZSH auto suggestions & completions
# not needed when using zsh-autocomplete
autoload compinit -Uz +X && compinit

# # Fix for Intel Mac, https://github.com/zsh-users/zsh-completions/issues/433#issuecomment-629539004
[[ $(uname -p) == "i386" ]] && compaudit | xargs chmod g-w

#───────────────────────────────────────────────────────────────────────────────

# must be loaded *before* zsh syntax highlighting
source "$ZDOTDIR/plugins/zsh-no-ps2/zsh-no-ps2.plugin.zsh"

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
