# good guide: https://thevaluable.dev/zsh-completion-guide-examples/
#───────────────────────────────────────────────────────────────────────────────

# case insensitive path-completion - https://scriptingosx.com/2019/07/moving-to-zsh-part-5-completions/
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 

# highlight selected completion item
zstyle ':completion:*' menu select

# group completions
zstyle ':completion:*' group-name ''
zstyle ':completion:*:*:-command-:*:*' group-order alias builtins functions commands

# coloring & messages
zstyle ':completion:*:*:*:*:descriptions' format '%F{blue}[%d]%f'
zstyle ':completion:*:messages' format '%F{blue}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{yellow}-- No completions found.%f'
# shellcheck disable=SC2086,SC2296
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# order files by last access
zstyle ':completion:*' file-sort access

# low priority match in word
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'


# only require one <tab> completion (the docs do not describe the actual
# behavior of the setting well) https://zsh.sourceforge.io/Doc/Release/Options.html#Completion-4
# setopt MENU_COMPLETE
