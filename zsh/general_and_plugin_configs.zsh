# shellcheck disable=SC2190

# sets English everywhere, so that programs behave predictably
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"

# OPTIONS --- (`man zshoptions` to see all options)
setopt AUTO_CD              # pure directory = cd into it
setopt INTERACTIVE_COMMENTS # comments in interactive mode (useful for copypasting)

#───────────────────────────────────────────────────────────────────────────────

# Broot Shell function https://dystroy.org/broot/install-br/
# (renamed `broot-shell` to avoid conflict with `br` for `brew reinstall`)
eval "$(broot --print-shell-function zsh | sed -e 's/function br /function broot-shell /')"

# you should use
export YSU_IGNORED_ALIASES=("bi" "bu") # due to homebrew Alfred workflow
export YSU_MESSAGE_POSITION="after"

# fzf
export FZF_DEFAULT_COMMAND='fd --hidden'
export FZF_DEFAULT_OPTS='--pointer=⟐ --prompt="❱ " --ellipsis=… --scroll-off=3 --cycle --bind="tab:up,shift-tab:down"'

# magic enter
export MAGIC_ENTER_GIT_COMMAND="inspect"
export MAGIC_ENTER_OTHER_COMMAND="inspect"

# zoxide
export _ZO_DATA_DIR="$DATA_DIR/zoxide/"
# export _ZO_EXCLUDE_DIRS=""
eval "$(zoxide init --no-cmd zsh)" # needs to be placed after compinit

#───────────────────────────────────────────────────────────────────────────────

# zsh syntax highlighting
export ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets regexp root)

# shellcheck disable=SC2034,SC2154
ZSH_HIGHLIGHT_STYLES[root]='bg=red' # highlight red when currently root

# # https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/regexp.md
typeset -A ZSH_HIGHLIGHT_REGEXP
# commit msgs too long
ZSH_HIGHLIGHT_REGEXP+=('^(gc|acp|git commit) "?.{50,}"?' 'fg=white,bold,bg=red')
# dangerous stuff
ZSH_HIGHLIGHT_REGEXP+=('(grh|git reset --hard|rm -r?f) .*' 'fg=white,bold,bg=red')
# NOTE: There are also some custom highlights for global aliases int eh aliases.zsh

export ZSH_AUTOSUGGEST_HISTORY_IGNORE="?(#c50,)" # ignores long history items
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
# do not accept autosuggestion when using vim `A`
export ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=("${ZSH_AUTOSUGGEST_ACCEPT_WIDGETS[@]/vi-add-eol/}")
