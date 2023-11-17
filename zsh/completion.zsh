# DOCS
# completion in zsh https://zsh.sourceforge.io/Guide/zshguide06.html
# zsh-autocomplete https://github.com/marlonrichert/zsh-autocomplete#configuration
# ansi colors https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797#256-colors
# good guide https://thevaluable.dev/zsh-completion-guide-examples/
#───────────────────────────────────────────────────────────────────────────────

# color completion groups #  https://stackoverflow.com/a/23568183
zstyle ':completion:*:descriptions' format $'\e[1;36m%d\e[0m'

# color items in specific group
zstyle ':completion:*:aliases' list-colors '=*=1;35'

zstyle ':completion:*:default:' list-colors "di=35"
# option descriptions in gray (38;5;245 is visible in dark and light mode)
# zstyle ':completion:*:default' list-colors '=(#b)*(-- *)=39=38;5;245' '=*=39'

# group order
# zstyle ':completion:*:git:*' group-order 'main commands' 'alias commands' 'external commands'

#───────────────────────────────────────────────────────────────────────────────

# <Tab> to cycle suggestions
# shellcheck disable=2154
bindkey '\t' menu-select "${terminfo}[kcbt]" menu-select
bindkey -M menuselect '\t' menu-complete "${terminfo}[kcbt]" reverse-menu-complete

# <CR> to select suggestion & execute
bindkey -M menuselect '\r' .accept-line

# hide info message if there are no completions https://github.com/marlonrichert/zsh-autocomplete/discussions/513
zstyle ':completion:*:warnings' format ""

# ZSH-AUTOCOMPLETE
# minimum number of characters before suggestions are shown
zstyle ':autocomplete:*' min-input 3
