# shellcheck disable=SC2139
# https://www.thorsten-hans.com/5-types-of-zsh-aliases


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
alias p='pass'


alias \?='betterApropos'
function betterApropos () {
	apropos -s1 "$*" | sed -E 's/(\d)//g'
}

# added verbosity
alias rm='rm -v'
alias mv='mv -v'
alias ln='ln -v'
alias cp='cp -v'

# defaults
alias grep='grep --ignore-case --color'
alias ls='ls -G' # colorize by default
alias which='which -a'
alias mkdir='mkdir -p'
alias pip="pip3"
alias curl="curl -sL"
alias tetris="tetris --ascii-only"

# exa
# in function for directoryInspect function
function exa() {
	command exa --all --icons --group-directories-first --sort=modified --ignore-glob=.DS_Store
}

alias exagit='git status --short; command echo; exa --long --grid --git --git-ignore --no-user --no-permissions --no-time --no-filesize --ignore-glob=.git'
alias l='command exa --all --long --git --icons --group-directories-first --sort=modified'
alias tree='command exa --tree -L4 --icons --git-ignore'
alias size="du -sh . ./* ./.* | sort -rh | sed 's/\\.\\///'" # size of files in current directory

# Global Alias (to be used at the end, mostly)
alias -s H="--help"
alias -s G="| grep --ignore-case --color"
alias -s B="| bat"
alias -s C="| pbcopy ; echo 'Copied.'"
alias -s J="| yq --prettyPrint --output-format=json --colors | less" # beautify in JSON
alias -s L="| less"
alias -s N="| wc -l | tr -d ' '"

# highlights for them
ZSH_HIGHLIGHT_REGEXP+=(' G$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' H$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' J$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' C$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' B$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' L$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' N$' 'fg=magenta,bold')

# SUFFIX ALIASES
# = default command to act upon the filetype, when is is entered
# ' and " are there to also open quoted things
# without preceding command (analogous to `setopt AUTO_CD` but for files)
alias -s {css,ts,js,yml,json,plist,xml,md}='bat'
alias -s {pdf,png,jpg,jpeg,tiff}="qlmanage -p &> /dev/null"

# open log files in less and scrolled to the bottom
alias -s log="less +G"
