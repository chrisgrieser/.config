# shellcheck disable=SC2190

#───────────────────────────────────────────────────────────────────────────────
# GENERAL SETTINGS

# sets English everywhere, so that programs behave predictably
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"

# OPTIONS --- (`man zshoptions` to see all options)
setopt AUTO_CD              # pure directory = cd into it
setopt INTERACTIVE_COMMENTS # comments in interactive mode (useful for copypasting)

#───────────────────────────────────────────────────────────────────────────────
# CLI SETTINGS

# you-should-use
export YSU_IGNORED_ALIASES=("bi" "bu") # due to homebrew Alfred workflow
export YSU_MESSAGE_POSITION="after"

# fd
# HACK fixes for `fd` colors when using a light terminal bg https://github.com/sharkdp/fd/issues/1031#issuecomment-1325716744
export EXA_COLORS="$LS_COLORS" # so exa does not loose it's colors (`man exa_colors`)
export LS_COLORS=''

# fzf
export FZF_DEFAULT_COMMAND='fd --hidden'
export FZF_DEFAULT_OPTS='--pointer=⟐ --prompt="❱ " --ellipsis=… --scroll-off=3 --cycle --layout=reverse --bind="tab:down,shift-tab:up" --preview-window=border-left --height="80%"'

# magic enter
export MAGIC_ENTER_GIT_COMMAND="inspect"
export MAGIC_ENTER_OTHER_COMMAND="inspect"

# zoxide
export _ZO_DATA_DIR="$DATA_DIR/zoxide/"
eval "$(zoxide init --no-cmd zsh)" # needs to be placed after compinit

#───────────────────────────────────────────────────────────────────────────────
# ZSH PLUGIN SETTINGS

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
