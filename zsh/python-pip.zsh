#!/usr/bin/env zsh

export PYTHONSTARTUP="$HOME/.config/python/pythonrc.py"

#───────────────────────────────────────────────────────────────────────────────

alias python="python3"

# 1. alias `pip update` to `pip3 install --upgrade` 
# 2. alias `pip uninstall` to `pip-autoremove`
# 3. other commands work as usual
function pip() {
	if [[ "$1" == "update" ]]; then
		shift
		set -- install --upgrade "$@"
	elif [[ "$1" == "uninstall" ]]; then
		if ! command -v pip-autoremove &>/dev/null; then print "\033[1;33mpip-autoremove not installed.\033[0m" && return 1; fi
		echo "Using pip-autoremove"
		shift
		pip-autoremove "$@"
	fi
	command pip3 "$@"
}
