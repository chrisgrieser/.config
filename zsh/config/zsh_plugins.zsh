# shellcheck disable=SC1091
#───────────────────────────────────────────────────────────────────────────────

# LOAD HOMEBREW COMPLETIONS
# load various completions of clis installed via homebrew
# needs to be run *before* compinit/zsh-autocomplete
export FPATH="$ZDOTDIR/completions:$HOMEBREW_PREFIX/share/zsh/site-functions:$FPATH"

# ZSH-COMPLETIONS
# also loads compinit stuff, therefore has to be loaded before most plugins
source "$HOMEBREW_PREFIX/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
# INFO not needed when using zsh-autocomplete
# autoload compinit -Uz +X && compinit
# [[ $(uname -p) == "i386" ]] && compaudit | xargs chmod g-w # FIX for Intel Mac, https://github.com/zsh-users/zsh-completions/issues/433#issuecomment-629539004

#───────────────────────────────────────────────────────────────────────────────

# ZSH-AUTOPAIR
source "$HOMEBREW_PREFIX/share/zsh-autopair/autopair.zsh"

#───────────────────────────────────────────────────────────────────────────────

# ZSH-SYNTAX-HIGHLIGHTING
# DOCS https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/regexp.md
source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
export ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets regexp)
# shellcheck disable=2034 # used in other files
typeset -A ZSH_HIGHLIGHT_REGEXP # actual highlights defined in other files

#───────────────────────────────────────────────────────────────────────────────

# ZSH-AUTOSUGGESTIONS
# https://github.com/zsh-users/zsh-autosuggestions#configuration
source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
export ZSH_AUTOSUGGEST_HISTORY_IGNORE="?(#c50,)" # ignores long history items
export ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd history completion)
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=30
bindkey '^Y' autosuggest-execute # remapped to `cmd+s` in WezTerm
# do not accept autosuggestion when using vim's `A`
export ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=("${ZSH_AUTOSUGGEST_ACCEPT_WIDGETS[@]/vi-add-eol/}")

#───────────────────────────────────────────────────────────────────────────────

# ZSH-HISTORY-SUBSTRING-SEARCH
# (must be loaded *after* zsh-syntax-highlighting)
source "$HOMEBREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
