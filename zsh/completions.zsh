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
bindkey -M menuselect 'K' vi-backward-blank-word # previous group
bindkey -M menuselect '^[[Z' accept-and-infer-next-history # shift+tab: for directories, query for children
bindkey -M menuselect ' ' accept-line
bindkey -M menuselect '\e' send-break
bindkey -M menuselect '^Z' undo
bindkey -M menuselect '^L' clear-screen

# coloring & messages
zstyle ':completion:*:*:*:*:descriptions' format '%F{blue}[%d]%f'
zstyle ':completion:*:messages' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{yellow}-- No completions found.%f'
# shellcheck disable=SC2086,SC2296
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# order files by last access
zstyle ':completion:*' file-sort access

# low priority match in word
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'


# only require one <tab> completion (the docs do not describe the actual
# behavior of the setting) https://zsh.sourceforge.io/Doc/Release/Options.html#Completion-4
setopt MENU_COMPLETE

#-------------------------------------------------------------------------------
# CLI-SPECIFIC COMPLETIONS

# Pandoc - https://groups.google.com/g/pandoc-discuss/c/Ot019yRiJFQ/m/VPchuJRkBQAJ
# (bashcompinit requires compinit, so compinit has to be autoloaded unless some other completion script has already done so.)

if which pandoc &> /dev/null; then
	autoload -U +X bashcompinit && bashcompinit
	eval "$(pandoc --bash-completion)"
fi

# pip
if which pip &> /dev/null; then
	eval "$(pip completion --zsh)"
	compctl -K _pip_completion pip3
fi

# NPM - https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/npm/npm.plugin.zsh
if which npm &> /dev/null; then
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
fi

# Homebrew Completions have to be added in .zprofile
# https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh
