# shellcheck disable=1091
#───────────────────────────────────────────────────────────────────────────────

export PIP_DISABLE_PIP_VERSION_CHECK=1

alias pu="pip uninstall"
alias pi="pip install"
alias pl="pip list --not-required"
alias freeze="pip freeze > requirements.txt && bat requirements.txt"
alias v="toggle_venv"

#───────────────────────────────────────────────────────────────────────────────

function new_venv {
	[[ -d ./.venv ]] && rm -rf ./.venv
	python3 -m venv ./.venv
	source ./.venv/bin/activate
	_inspect_venv
}

function toggle_venv {
	if [[ -n "$VIRTUAL_ENV" ]]; then
		deactivate
		_inspect_venv
	else
		local venv_path
		venv_path=$(_search_venv_path)
		if [[ -n "$venv_path" ]]; then
			# shellcheck disable=1091
			source "$venv_path/bin/activate"
			_inspect_venv
		else
			print "\e[1;33mNo virtual environment found.\e[0m"
		fi
	fi
}

#───────────────────────────────────────────────────────────────────────────────

function _inspect_venv {
	py_path="$(command which python3 | sed "s|^$HOME/|~/|")"
	if [[ "$py_path" =~ \.venv ]]; then
		print "\e[1;33mVIRTUAL_ENV \e[1;32menabled\e[0m"
	else
		print "\e[1;33mVIRTUAL_ENV \e[1;31mdisabled\e[0m"
	fi
	print "Now using: $py_path ($(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2))"
}

function _search_venv_path {
	local dir_to_check=$PWD
	while true; do
		if [[ -d "$dir_to_check/.venv" ]]; then
			echo "$dir_to_check/.venv"
			return
		elif [[ "$dir_to_check" == "/" ]]; then
			return
		fi
		dir_to_check=$(dirname "$dir_to_check")
	done
}

# Intended for use with `chpwd`. Automatically enables venv if current dir or a
# parent has a `.venv` dir, and disables venv if not.
function _auto_venv {
	local venv_path
	venv_path=$(_search_venv_path)

	if [[ -n "$VIRTUAL_ENV" && -z "$venv_path" ]]; then
		deactivate
		echo && _inspect_venv
	elif [[ -z "$VIRTUAL_ENV" && -n "$venv_path" ]]; then
		source "$venv_path/bin/activate"
		echo && _inspect_venv
	fi
}
