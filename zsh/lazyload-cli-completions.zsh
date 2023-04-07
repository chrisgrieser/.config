# INFO Lazy loading explanations
# https://frederic-hemberger.de/notes/shell/speed-up-initial-zsh-startup-with-lazy-loading/)
#───────────────────────────────────────────────────────────────────────────────

# Homebrew Completions added in .zprofile
# https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh

if command -v npm &> /dev/null; then
	npm() {
		unfunction "$0" # Remove this function, subsequent calls will execute 'kubectl' directly
		$0 "$@" # Execute binary
		eval "$(npm completion)" # https://docs.npmjs.com/cli/v8/commands/npm-completion
	}
fi

# if command -v pip3 &> /dev/null; then
# 	pip3(){
# 		unfunction "$0"
# 		$0 "$@"
# 		eval "$(pip3 completion --zsh)"# https://askubuntu.com/a/1026594
# 	}
# fi

if command -v pandoc &> /dev/null; then
	pandoc(){
		unfunction "$0"
		$0 "$@"
		autoload -U +X bashcompinit && bashcompinit # (bashcompinit requires compinit, so compinit has to be autoloaded unless some other completion script has already done so.)
		eval "$(pandoc --bash-completion)" # https://groups.google.com/g/pandoc-discuss/c/Ot019yRiJFQ/m/VPchuJRkBQAJ
	}
fi

