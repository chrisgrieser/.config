alias pu="python3 -m pip uninstall"
alias pl="python3 -m pip list --not-required"
alias py="python3"
alias bye="wezterm cli spawn -- bpython"

# Prevent accidental installation outside of virtual env
function pi() {
	if [[ -z "$VIRTUAL_ENV" ]]; then
		printf "\033[1;33mAre you sure you want to install outside of a virtual environment? (y/n)\033[0m "
		read -r answer
		if [[ "$answer" != "y" ]]; then return 2; fi
	fi
	python3 -m pip install "$@"
}

#───────────────────────────────────────────────────────────────────────────────

# VIRTUAL_ENV

function _search_venv_path() {
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
function _auto_venv() {
	local venv_path
	venv_path=$(_search_venv_path)

	if [[ -n "$VIRTUAL_ENV" && -z "$venv_path" ]]; then
		deactivate
	elif [[ -z "$VIRTUAL_ENV" && -n "$venv_path" ]]; then
		# shellcheck disable=1091
		source "$venv_path/bin/activate"
	fi
}

# toggle virtual environment
function v() {
	if [[ -n "$VIRTUAL_ENV" ]]; then
		deactivate
		return
	else
		local venv_path
		venv_path=$(_search_venv_path)
		if [[ -n "$venv_path" ]]; then
			# shellcheck disable=1091
			source ./.venv/bin/activate
		else
			print "\033[1;33mNo virtual environment found.\033[0m"
		fi
	fi
}
