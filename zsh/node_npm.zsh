# Don't clutter home directory with useless `.node_repl_history`
# https://nodejs.org/api/repl.html#repl_environment_variable_options
export NODE_REPL_HISTORY=""

#───────────────────────────────────────────────────────────────────────────────

# instead of writing npm config to ~/.npmrc, they can also be defined as shell
# environment variables https://docs.npmjs.com/cli/v9/using-npm/config#environment-variables

# disable funding reminder, has to be lowercase
export npm_config_fund=false


# Lazy-load conda environment, to improve performance and also to prevent conda
# taking over the prompt until it is needed
function conda {
	unfunction "$0"
	conda_prefix="$(brew --prefix)/anaconda3/bin" # change depending on where/hoow conda was installed

	export PATH="$conda_prefix":$PATH
	if [[ ! -x "$(command -v "$0")" ]]; then print "\033[1;33mconda not installed.\033[0m" && return 1; fi

	# setup snippet that `conda init zsh` adds to your `.zshrc`
	__conda_setup="$("$conda_prefix/conda" 'shell.zsh' 'hook' 2> /dev/null)"
	eval "$__conda_setup"

	$0 "$@"
}
