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
	local python="python3.13" # CONFIG

	if [[ ! -x "$(command -v $python)" ]]; then
		print "\e[0;33m\`$python\` not installed.\e[0m" 
		return 1
	fi
	[[ -d ./.venv ]] && rm -rf ./.venv
	"$python" -m venv ./.venv
	source ./.venv/bin/activate
	inspect_venv
}

function inspect_venv {
	py_path="$(command which python3 | sed "s|^$HOME/|~/|")"
	print "Now using: \e[1;36m$py_path\e[0m"
}

function _search_venv_path {
	local dir_to_check=$PWD
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

# Utility function, intended for use with `chpwd`. Automatically enables
# venv if current dir or a parent has a `.venv` dir. Disables venv if not.
function _auto_venv {
	local venv_path
	venv_path=$(_search_venv_path)

	if [[ -n "$VIRTUAL_ENV" && -z "$venv_path" ]]; then
		deactivate
		echo && inspect_venv
	elif [[ -z "$VIRTUAL_ENV" && -n "$venv_path" ]]; then
		source "$venv_path/bin/activate"
		echo && inspect_venv
	fi
}

function toggle_venv {
	if [[ -n "$VIRTUAL_ENV" ]]; then
		deactivate
		inspect_venv
	else
		local venv_path
		venv_path=$(_search_venv_path)
		if [[ -n "$venv_path" ]]; then
			# shellcheck disable=1091
			source ./.venv/bin/activate
			inspect_venv
		else
			print "\e[1;33mNo virtual environment found.\e[0m"
		fi
	fi
}
