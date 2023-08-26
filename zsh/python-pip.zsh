#!/usr/bin/env zsh

export PYTHONSTARTUP="$HOME/.config/python/pythonrc.py"

#───────────────────────────────────────────────────────────────────────────────

alias py="python3"
alias pu="pip uninstall"
alias pi="pip install"
alias pl="pip list"

# toggle virtual environment
function v() {
	if [[ -n "$VIRTUAL_ENV" ]]; then
		deactivate
	else
		# shellcheck disable=1091
		source venv/bin/activate
	fi
}

# 1. alias `pip update` to `pip3 install --upgrade` 
# 2. alias `pip uninstall` to `pip-autoremove`
# 3. other commands work as usual
function pip() {
	if [[ "$1" == "update" ]]; then
		shift
		command pip3 install --upgrade "$@"
	elif [[ "$1" == "uninstall" ]]; then
		if ! command -v pip-autoremove &>/dev/null; then print "\033[1;33mpip-autoremove not installed.\033[0m" && return 1; fi
		print "\033[1;34mUsing pip-autoremove\033[0m"
		shift
		pip-autoremove "$@"
	else
		command pip3 "$@"
	fi
}
