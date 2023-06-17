# shellcheck disable=2139

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

alias bkp='zsh "$DOTFILE_FOLDER/_utility-scripts/backup-script.sh"'

alias l='exa --all --long --git --icons --group-directories-first --sort=modified'
alias tree='exa --tree --level=4 --icons --git-ignore'
alias tree-dir='exa --only-dirs --tree --level=4 --icons --git-ignore'
alias size="du -sh . ./* ./.* | sort -rh | sed 's/\\.\\///'" # size of files in current directory

#───────────────────────────────────────────────────────────────────────────────
# https://www.thorsten-hans.com/5-types-of-zsh-aliases

# SUFFIX Alias
alias -s {yml,yaml}=yq
alias -s json='yq --prettyPrint --output-format=json --colors '
alias -s {gif,png,jpg,jpeg,webp}='qlmanage -p'
alias -s {md,lua,js,ts,css,sh,zsh,applescript}=bat

# GLOBAL ALIAS (to be used at the end, mostly)
alias -g H="--help"
alias -g G="| grep --ignore-case --color"
alias -g B="| bat"
alias -g C="| pbcopy ; echo 'Copied.'"                               # copy
alias -g J="| yq --prettyPrint --output-format=json --colors | less" # beautify in JSON
alias -g N="| wc -l | tr -d ' '"                                     # count lines

# highlights for them
ZSH_HIGHLIGHT_REGEXP+=(' G$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' G ' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' H$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' J$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' C$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' B$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' N$' 'fg=magenta,bold')
