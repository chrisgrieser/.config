# shellcheck disable=SC1091

# ZSH-AUTOSUGGESTIONS
# https://github.com/zsh-users/zsh-autosuggestions#configuration
source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
export ZSH_AUTOSUGGEST_HISTORY_IGNORE="?(#c50,)" # ignores long history items
export ZSH_AUTOSUGGEST_STRATEGY=(history)
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=35
# do not accept autosuggestion when using vim's `A`
export ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=("${ZSH_AUTOSUGGEST_ACCEPT_WIDGETS[@]/vi-add-eol/}")

# ZSH-AUTOPAIR
source "$HOMEBREW_PREFIX/share/zsh-autopair/autopair.zsh"

# ZSH-SYNTAX-HIGHLIGHTING
# DOCS https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/regexp.md
source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
export ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets regexp)
# shellcheck disable=2034 # variable is used in other config files
typeset -A ZSH_HIGHLIGHT_REGEXP # just declaration, my custom highlights are defined in other files

# ZSH-HISTORY-SUBSTRING-SEARCH
# (must be loaded *after* zsh-syntax-highlighting)
source "$HOMEBREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
bindkey '^[[A' history-substring-search-up   # arrow up
bindkey '^[[B' history-substring-search-down # arrow down

# SEMANTIC PROMPTS (WEZTERM) https://wezfurlong.org/wezterm/shell-integration
[[ "$TERM_PROGRAM" == "WezTerm" ]] && source "$ZDOTDIR/../wezterm/semantic_prompts.zsh"

# STARSHIP
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"
