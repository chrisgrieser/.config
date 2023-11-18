# DOCS
# official docs https://zsh.sourceforge.io/Guide/zshguide06.html
# good guide https://thevaluable.dev/zsh-completion-guide-examples/
# zsh-autocomplete https://github.com/marlonrichert/zsh-autocomplete#configuration
# ansi colors https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797#256-colors
#───────────────────────────────────────────────────────────────────────────────

# color completion groups with pruple-gray background (ccc.nvim highlight is wrong)
zstyle ':completion:*:descriptions' format $'\e[7;38;5;103m %d \e[0;38;5;103m\e[0m'

# color items in specific group
zstyle ':completion:*:aliases' list-colors '=*=35'

# 1. option descriptions in gray (`38;5;245` is visible in dark and light mode)
# 2. apply LS_COLORS
# 3. selected item (styled via `ma=`)
zstyle ':completion:*:default' list-colors \
	'=(#b)*(-- *)=39=38;5;245' \
	"$LS_COLORS" \
	"ma=7;38;5;68"

# group order
zstyle ':completion:*:*:-command-:*:*' group-order \
	directories alias builtins functions commands

# hide info message if there are no completions https://github.com/marlonrichert/zsh-autocomplete/discussions/513
zstyle ':completion:*:warnings' format ""

#───────────────────────────────────────────────────────────────────────────────

# <Tab> to cycle suggestions
# shellcheck disable=2154
bindkey '\t' menu-select "${terminfo}[kcbt]" menu-select
bindkey -M menuselect '\t' menu-complete "${terminfo}[kcbt]" reverse-menu-complete

# <S-Tab> to go to next group
bindkey -M menuselect '^[[Z' vi-forward-blank-word

# <CR> to select suggestion & execute
bindkey -M menuselect '\r' .accept-line

#───────────────────────────────────────────────────────────────────────────────
# ZSH-AUTOCOMPLETE

zstyle ':autocomplete:*' min-input 2
zstyle ':autocomplete:*' ignored-input '..d'
