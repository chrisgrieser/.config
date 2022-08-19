# shellcheck disable=SC2190

# zsh syntax highlighting
export ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets regexp root)

# shellcheck disable=SC2034,SC2154
ZSH_HIGHLIGHT_STYLES[root]='bg=red' # highlight red when currently root

# # https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/regexp.md
typeset -A ZSH_HIGHLIGHT_REGEXP
ZSH_HIGHLIGHT_REGEXP+=('^(git commit -m|acp|amend) .{50,}' 'fg=white,bold,bg=red') # commit msgs too long
ZSH_HIGHLIGHT_REGEXP+=('(git reset --hard|rm -r?f) .*' 'fg=white,bold,bg=red') # dangerous stuff

#-------------------------------------------------------------

export BAT_THEME='Sublime Snazzy'

export ZSH_AUTOSUGGEST_HISTORY_IGNORE="?(#c50,)" # ignores long history items
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
# do not accept autosuggestion when using vim `A`
export ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=( "${ZSH_AUTOSUGGEST_ACCEPT_WIDGETS[@]/vi-add-eol/}" )

export FZF_DEFAULT_COMMAND='fd --hidden'
export FZF_DEFAULT_OPTS='-0 --pointer=⟐ --prompt="❱ "'

export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export EDITOR='subl --new-window --wait'

# OPTIONS --- (`man zshoptions` to see all options)
setopt AUTO_CD # pure directory = cd into it
setopt INTERACTIVE_COMMENTS # comments in interactive mode (useful für copypasting)

# MAGIC ENTER
export MAGIC_ENTER_GIT_COMMAND="git status -s ; br"
export MAGIC_ENTER_OTHER_COMMAND="br"

function directoryInspect (){
	if command git rev-parse --is-inside-work-tree &>/dev/null ; then
		git status --short
		echo
	fi
	if [[ $(ls | wc -l) -lt 20 ]] ; then
		exa
	fi
}
