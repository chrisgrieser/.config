# good guide: https://thevaluable.dev/zsh-completion-guide-examples/
#-------------------------------------------------------------------------------

# case insensitive path-completion - https://scriptingosx.com/2019/07/moving-to-zsh-part-5-completions/
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 

# highlight selected completion item
zstyle ':completion:*' menu select

# group completions
zstyle ':completion:*' group-name ''
zstyle ':completion:*:*:-command-:*:*' group-order alias builtins functions commands

# Use vim keys in tab complete menu
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'J' vi-forward-blank-word # next group
bindkey -M menuselect '^M' accept-and-infer-next-history
bindkey -M menuselect ' ' accept-and-infer-next-history


# coloring & messages
zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# order files by last access
zstyle ':completion:*' file-sort access

# low priority match in word
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

setopt AUTO_MENU
#-------------------------------------------------------------------------------
# CLI-SPECIFIC COMPLETIONS

# Pandoc - https://groups.google.com/g/pandoc-discuss/c/Ot019yRiJFQ/m/VPchuJRkBQAJ
# (bashcompinit requires compinit, so compinit has to be autoloaded unless some other completion script has already done so.)
autoload -U +X bashcompinit && bashcompinit
eval "$(pandoc --bash-completion)"

# pip
eval "$(pip completion --zsh)"
compctl -K _pip_completion pip3

# NPM - https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/npm/npm.plugin.zsh
# shellcheck disable=SC2154
(( $+commands[npm] )) && {
  rm -f "${ZSH_CACHE_DIR:-$ZSH/cache}/npm_completion"

  _npm_completion() {
    local si=$IFS
    compadd -- $(COMP_CWORD=$((CURRENT-1)) \
                 COMP_LINE=$BUFFER \
                 COMP_POINT=0 \
                 npm completion -- "${words[@]}" \
                 2>/dev/null)
    IFS=$si
  }
  compdef _npm_completion npm
}

# Homebrew Completions have to be added in .zprofile
# https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh
