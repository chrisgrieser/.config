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
setopt MENU_COMPLETE

#───────────────────────────────────────────────────────────────────────────────
# CLI-SPECIFIC COMPLETIONS

# Homebrew Completions added in .zprofile
# https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh

# Lazy loading to decrease loading time:
# https://frederic-hemberger.de/notes/shell/speed-up-initial-zsh-startup-with-lazy-loading/)
if command -v npm &> /dev/null; then
	npm() {
		unfunction "$0" # Remove this function, subsequent calls will execute 'kubectl' directly
		$0 "$@" # Execute binary
		eval "$(npm completion)" # https://docs.npmjs.com/cli/v8/commands/npm-completion
	}
fi

if command -v pip3 &> /dev/null; then
	pip3(){
		unfunction "$0"
		$0 "$@"
		eval "$(pip3 completion --zsh)"# https://askubuntu.com/a/1026594
	}
fi

if command -v pandoc &> /dev/null; then
	pandoc(){
		unfunction "$0"
		$0 "$@"
		autoload -U +X bashcompinit && bashcompinit # (bashcompinit requires compinit, so compinit has to be autoloaded unless some other completion script has already done so.)
		eval "$(pandoc --bash-completion)" # https://groups.google.com/g/pandoc-discuss/c/Ot019yRiJFQ/m/VPchuJRkBQAJ
	}
fi

