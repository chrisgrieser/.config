# shellcheck disable=1091
#───────────────────────────────────────────────────────────────────────────────

# 1. Prevent accidental installation outside of virtual env
# 2. Use `python3 -m pip` instead of `pip3`
function pip {
	if [[ "$1" == "install" ]]; then
		if [[ ! "$(cmd which python3)" =~ /\.venv/ || -z "$VIRTUAL_ENV" ]]; then
			printf "\033[1;33mNot in a virtual environment. Aborting.\033[0m "
			return
		fi
	fi
	python3 -m pip "$@"
}

alias pu="pip uninstall"
alias pi="pip install"
alias pl="pip list --not-required"
alias py="python3"
alias bye="wezterm cli spawn -- bpython"
alias v="toggle_venv"

#───────────────────────────────────────────────────────────────────────────────

function new_venv {
	[[ -d ./.venv ]] && rm -rf ./.venv
	python3 -m venv ./.venv
	source ./.venv/bin/activate
	python3 -m pip install --upgrade pip # to remove update nagging
	inspect_venv
}

function inspect_venv { printf "\n\e[1;33mNow using: \e[1;36m%s\e[0m\n" "$(cmd which python3)"; }

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

# Utility function, intended for terminal movement commands. Automatically enables
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
			print "\033[1;33mNo virtual environment found.\033[0m"
		fi
	fi
}
