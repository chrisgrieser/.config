#!/usr/bin/env zsh

export IPYTHONDIR="$HOME/.config/ipython"

#───────────────────────────────────────────────────────────────────────────────

alias pu="pip uninstall"
alias pi="pip install"
alias pl="pip list --not-required"
alias py="python3"
alias jn="jupyter notebook"

#───────────────────────────────────────────────────────────────────────────────

function search_venv_path() {
	dir_to_check=$PWD
	while true; do
		if [[ -d "$dir_to_check/.venv" ]]; then
			local venv_path="$dir_to_check/.venv"
			break
		elif [[ "$dir_to_check" == "/" ]]; then
			break
		fi
		dir_to_check=$(dirname "$dir_to_check")
	done
	echo "$venv_path"
}

# toggle virtual environment
function v() {
	if [[ -n "$VIRTUAL_ENV" ]]; then
		deactivate
	else
		local venv_path
		venv_path=$(search_venv_path)
		if [[ -n "$venv_path" ]]; then
			# shellcheck disable=1091
			source ./.venv/bin/activate
		else
			print "\033[1;33mNo virtual environment found.\033[0m"
		fi
	fi
}

# Utility function, intended terminal movement commands. Automatically enables
# venv if current dir or a parent has a `.venv` dir. Disables venv if not.
function auto_venv() {
	local venv_path
	venv_path=$(search_venv_path)

	if [[ -n "$VIRTUAL_ENV" && -z "$venv_path" ]]; then
		deactivate
	elif [[ -z "$VIRTUAL_ENV" && -n "$venv_path" ]]; then
		# shellcheck disable=1091
		source "$venv_path/bin/activate"
	fi
}

function cd() {
	builtin cd "$@" || return 1
	auto_venv
}

#───────────────────────────────────────────────────────────────────────────────

# 1. Prevent accidental installation outside of virtual env
# 2. alias `pip uninstall` to `pip-autoremove`
# 3. other commands work as usual
function pip() {
	if [[ "$1" == "install" && -z "$VIRTUAL_ENV" ]]; then
		print "\033[1;33mAre you sure you want to install outside of a virtual environment? (Y/n)\033[0m"
		read -rk answer
		if [[ "$answer" != "Y" ]]; then return 2; fi
		pip3 "$@"
	elif [[ "$1" == "uninstall" ]] && [[ -z "$VIRTUAL_ENV" ]]; then
		if ! command -v pip-autoremove &>/dev/null; then print "\033[1;33mpip-autoremove not installed.\033[0m" && return 1; fi
		print "\033[1;34mUsing pip-autoremove\033[0m"
		shift
		pip-autoremove "$@"
	else
		pip3 "$@"
	fi
}

#───────────────────────────────────────────────────────────────────────────────
# ANACONDA

# Lazy-load conda environment, to improve performance and also to prevent conda
# taking over the prompt until it is needed
function conda {
	unfunction conda
	conda_prefix="$(brew --prefix)/anaconda3/bin" # change depending on where/hoow conda was installed

	export PATH="$conda_prefix":$PATH
	if [[ ! -x "$(command -v conda)" ]]; then print "\033[1;33mconda not installed.\033[0m" && return 1; fi

	# setup snippet that `conda init zsh` adds to your `.zshrc`
	__conda_setup="$("$conda_prefix/conda" 'shell.zsh' 'hook' 2> /dev/null)"
	eval "$__conda_setup"

	conda "$@"
}
