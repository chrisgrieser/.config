#!/usr/bin/env zsh

# export PYTHONSTARTUP="$DOTFILE_FOLDER/python/pythonrc.py"
export IPYTHONDIR="$DOTFILE_FOLDER/ipython"

#───────────────────────────────────────────────────────────────────────────────

alias ip="ipython"
alias pu="pip uninstall"
alias pi="pip install"
alias pl="pip list --not-required"

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

	if [[ -n "$VIRTUAL_ENV" && -z "$venv_path" ]] ; then
		deactivate
	elif [[ -z "$VIRTUAL_ENV" && -n "$venv_path" ]] ; then
		# shellcheck disable=1091
		source "$venv_path/bin/activate"
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
	if ! command -v ct &>/dev/null; then print "\033[1;33mct not installed.\033[0m" && return 1; fi
	
	if [[ "$1" == "update" ]]; then
		shift
		ct command pip3 install --upgrade "$@"
	elif [[ "$1" == "uninstall" ]] && [[ -z "$VIRTUAL_ENV" ]]; then
		if ! command -v pip-autoremove &>/dev/null; then print "\033[1;33mpip-autoremove not installed.\033[0m" && return 1; fi
		print "\033[1;34mUsing pip-autoremove\033[0m"
		shift
		pip-autoremove "$@"
	else
		ct command pip3 "$@"
	fi
}
