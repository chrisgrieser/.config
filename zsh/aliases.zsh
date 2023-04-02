# shellcheck disable=SC2139

# aliases not triggering "you should use"
export YSU_IGNORED_ALIASES=("bi" "bu") # due to homebrew Alfred workflow

#───────────────────────────────────────────────────────────────────────────────

# z & cd
alias zz='z -' # back to last dir
alias .="open ."
alias ..="z .."
alias ...="z ../.."
alias ....="z ../../.."
alias .....="z ../../../.."

# utils
alias r='exec zsh' # do not reload with source ~/.zshrc, https://github.com/ohmyzsh/ohmyzsh/wiki/FAQ#how-do-i-reload-the-zshrc-file
alias q='exit'
alias notify="osascript -e 'display notification \"\" with title \"Terminal Process finished.\" subtitle \"\" sound name \"\"'"

# added verbosity
alias mv='mv -v'
alias ln='ln -v'
alias cp='cp -v'

# defaults
alias grep='grep --ignore-case --color'
alias ls='ls -G'       # colorize by default
alias which='which -a' # show all
alias mkdir='mkdir -p' # create intermediate directories
alias pip="pip3"
alias curl="curl -sL" # silent & redirect

# misc
alias prose='ssh nanotipsforvim@prose.sh'

# effectively alias `pip3 update` to `pip3 install --upgrade`
function pip3() {
	if [[ "$1" == "update" ]]; then
		shift
		set -- install --upgrade "$@"
	fi
	command pip3 "$@"
}

#───────────────────────────────────────────────────────────────────────────────

# EXA (function and not alias for `directoryInspect`)
function exa() {
	command exa --all --icons --group-directories-first --sort=modified --ignore-glob=.DS_Store
}

alias exagit='git status --short; command echo; exa --long --grid --git --git-ignore --no-user --no-permissions --no-time --no-filesize --ignore-glob=.git'
alias l='command exa --all --long --git --icons --group-directories-first --sort=modified'
alias t='command exa --tree -L4 --icons --git-ignore'
alias size="du -sh . ./* ./.* | sort -rh | sed 's/\\.\\///'" # size of files in current directory

#───────────────────────────────────────────────────────────────────────────────
# https://www.thorsten-hans.com/5-types-of-zsh-aliases

# GLOBAL ALIAS (to be used at the end, mostly)
alias -g H="--help"
alias -g G="| grep --ignore-case --color"
alias -g B="| bat"
alias -g C="| pbcopy ; echo 'Copied.'"                               # copy
alias -g J="| yq --prettyPrint --output-format=json --colors | less" # beautify in JSON
alias -g L="| less"                                                  # Less
alias -g N="| wc -l | tr -d ' '"                                     # count lines

# highlights for them
ZSH_HIGHLIGHT_REGEXP+=(' G$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' G ' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' H$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' J$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' C$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' B$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' L$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' N$' 'fg=magenta,bold')
