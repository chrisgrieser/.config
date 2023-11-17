# group order
zstyle ':completion:*:git:*' group-order 'main commands' 'alias commands' 'external commands'

# group commands & color groups
# see https://github.com/marlonrichert/zsh-autocomplete/issues/654
zstyle ':completion:*:descriptions' format $'\e[1;36m%d\e[0m'

# ZSH-AUTOCOMPLETE
# DOCS https://github.com/marlonrichert/zsh-autocomplete#configuration

# <Tab> to cycle suggestions
# shellcheck disable=2154
bindkey '\t' menu-select "${terminfo}[kcbt]" menu-select
bindkey -M menuselect '\t' menu-complete "${terminfo}[kcbt]" reverse-menu-complete

# <CR> to select suggestion & execute
bindkey -M menuselect '\r' .accept-line

# hide info message if there are no completions https://github.com/marlonrichert/zsh-autocomplete/discussions/513
zstyle ':completion:*:warnings' format ""

# minimum number of characters before suggestions are shown
zstyle ':autocomplete:*' min-input 3
