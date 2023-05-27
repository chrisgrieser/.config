# shellcheck disable=1087,2154
#───────────────────────────────────────────────────────────────────────────────

# https://github.com/marlonrichert/zsh-autocomplete#configuration
# ZSH autocomplete: Tab cycles completions
bindkey '\t' menu-select "$terminfo[kcbt]" menu-select
bindkey -M menuselect '\t' menu-complete "$terminfo[kcbt]" reverse-menu-complete

#───────────────────────────────────────────────────────────────────────────────

# case insensitive path-completion - https://scriptingosx.com/2019/07/moving-to-zsh-part-5-completions/
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 

#───────────────────────────────────────────────────────────────────────────────

# colorful completions https://thevaluable.dev/zsh-completion-guide-examples/
zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{blue} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{yellow}-- %d --%f'
# shellcheck disable=SC2086,SC2296
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

