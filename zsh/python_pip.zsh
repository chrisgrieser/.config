#!/usr/bin/env zsh

# export PYTHONSTARTUP="$DOTFILE_FOLDER/python/pythonrc.py"
export IPYTHONDIR="$DOTFILE_FOLDER/ipython"

#───────────────────────────────────────────────────────────────────────────────

alias ip="ipython"
alias pu="pip uninstall"
alias pi="pip install"
alias pl="pip list --not-required"

#───────────────────────────────────────────────────────────────────────────────

# toggle virtual environment
function v() {
	if [[ -n "$VIRTUAL_ENV" ]]; then
		deactivate
	elif [[ -z "$VIRTUAL_ENV" && -d ".venv" ]] ; then
		# shellcheck disable=1091
		source ./.venv/bin/activate
	elif [[ -z "$VIRTUAL_ENV" && ! -d ".venv" ]] ; then
		print "\033[1;33mNo virtual environment found.\033[0m"
	fi
}

# utility function, used by all terminal movement commands
function auto_venv() {
	if [[ -n "$VIRTUAL_ENV" && ! -d ".venv" ]] ; then
		deactivate
	elif [[ -z "$VIRTUAL_ENV" && -d ".venv" ]] ; then
		# shellcheck disable=1091
		source ./.venv/bin/activate
	fi
}

function cd() {
	builtin cd "$@" || return 1
	auto_venv
}

#───────────────────────────────────────────────────────────────────────────────

# 1. alias `pip update` to `pip3 install --upgrade`
# 2. alias `pip uninstall` to `pip-autoremove`
# 3. other commands work as usual
function pip() {
	if [[ "$1" == "update" ]]; then
		shift
		command pip3 install --upgrade "$@"
	elif [[ "$1" == "uninstall" ]] && [[ -z "$VIRTUAL_ENV" ]]; then
		if ! command -v pip-autoremove &>/dev/null; then print "\033[1;33mpip-autoremove not installed.\033[0m" && return 1; fi
		print "\033[1;34mUsing pip-autoremove\033[0m"
		shift
		pip-autoremove "$@"
	else
		command pip3 "$@"
	fi
}
