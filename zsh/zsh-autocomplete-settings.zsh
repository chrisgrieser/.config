# shellcheck disable=1087,2154
# https://github.com/marlonrichert/zsh-autocomplete#configuration
#───────────────────────────────────────────────────────────────────────────────

# Tab cycles completions
bindkey '\t' menu-select "$terminfo[kcbt]" menu-select
bindkey -M menuselect '\t' menu-complete "$terminfo[kcbt]" reverse-menu-complete

# case insensitive path-completion - https://scriptingosx.com/2019/07/moving-to-zsh-part-5-completions/
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 

# shellcheck disable=2296
# colorfule completions
zstyle ':completion:*:parameters'  list-colors '=*=31'
zstyle ':completion:*:options' list-colors '=^(--*)=34'
