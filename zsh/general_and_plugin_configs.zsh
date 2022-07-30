# shellcheck disable=SC2190

# zsh syntax highlighting
export ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern regexp root)
typeset -A ZSH_HIGHLIGHT_PATTERNS # https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/pattern.md
ZSH_HIGHLIGHT_PATTERNS+=('rm -r?f' 'fg=white,bold,bg=red') # `rm -f` in red
ZSH_HIGHLIGHT_PATTERNS+=('rm -f' 'fg=white,bold,bg=red')
ZSH_HIGHLIGHT_PATTERNS+=('git reset' 'fg=white,bold,bg=red') # `git reset` in red

# shellcheck disable=SC2034,SC2154
ZSH_HIGHLIGHT_STYLES[root]='bg=red' # highlight red when currently root

# # https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/regexp.md
typeset -A ZSH_HIGHLIGHT_REGEXP
ZSH_HIGHLIGHT_REGEXP+=('^(git commit -m|acp|amend) .{50,}' 'fg=white,bold,bg=red') # commit msgs too long
ZSH_HIGHLIGHT_REGEXP+=('(git reset|rm -r?f) .*' 'fg=white,bold,bg=red') # dangerous stuff

#-------------------------------------------------------------

export BAT_THEME='Sublime Snazzy'

export ZSH_AUTOSUGGEST_HISTORY_IGNORE="?(#c50,)" # ignores long history items
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
# do not accept autosuggestion when using vim `A`
export ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=( "${ZSH_AUTOSUGGEST_ACCEPT_WIDGETS[@]/vi-add-eol/}" )

export FZF_DEFAULT_COMMAND='fd --hidden'
export FZF_DEFAULT_OPTS='-0 --pointer=⟐ --prompt="❱ "'

export MAGIC_ENTER_GIT_COMMAND="exagit"
export MAGIC_ENTER_OTHER_COMMAND="exa"

export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"

# OPTIONS --- (`man zshoptions` to see all options)
setopt AUTO_CD # pure directory = cd into it
setopt INTERACTIVE_COMMENTS # comments in interactive mode (useful für copypasting)

export EDITOR='subl --new-window --wait'
