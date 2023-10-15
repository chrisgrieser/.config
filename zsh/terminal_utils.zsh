# Quick Open File
function o() {
	if ! command -v fzf &>/dev/null; then print "\033[1;33mfzf not installed.\033[0m" && return 1; fi
	if ! command -v fd &>/dev/null; then print "\033[1;33mfd not installed.\033[0m" && return 1; fi
	if ! command -v eza &>/dev/null; then print "\033[1;33meza not installed.\033[0m" && return 1; fi
	if ! command -v bat &>/dev/null; then print "\033[1;33mbat not installed.\033[0m" && return 1; fi

	local input="$*"

	# skip `fzf` if file is fully named, e.g. through tab completion
	if [[ -f "$input" ]]; then
		open "$input"
		return 0
	fi

	# --delimiter and --nth options ensure only file name and parent folder are displayed
	local selected
	selected=$(
		fd --type=file --type=symlink --color=always | fzf \
			-0 -1 --ansi --query="$input" --info=inline \
			--header="^H --hidden --no-ignore   ^D directories" \
			--bind="ctrl-h:reload(fd --hidden --no-ignore --exclude='/.git/' --exclude='.DS_Store' --type=file --type=symlink --color=always)" \
			--preview '[[ -f {} ]] && bat --color=always --style=snip --wrap=never --tabs=2 {} || eza --icons --color=always --group-directories-first {}'
	)
	if [[ -z "$selected" ]]; then # fzf aborted
		return 0
	elif [[ -f "$selected" ]]; then
		open "$selected"
	else
		return 1
	fi
}

#───────────────────────────────────────────────────────────────────────────────

# smarter z/cd
# after entering new folder, inspect it (eza, git log, git status, etc.)
function z() {
	if ! command -v __zoxide_z &>/dev/null; then printf "\033[1;33mzoxide not installed.\033[0m" && return 1; fi
	__zoxide_z "$1"
	inspect
	auto_venv
}

function w {
	if ! command -v walk &>/dev/null; then print "\033[1;33mwalk not installed.\033[0m" && return 1; fi
	if ! command -v __zoxide_z &>/dev/null; then printf "\033[1;33mzoxide not installed.\033[0m" && return 1; fi
	export WALK_EDITOR="open" # opens via macos default app
	z "$(walk --icons "$@")"
}

# back to last directory
function zz() {
	if ! command -v __zoxide_z &>/dev/null; then printf "\033[1;33mzoxide not installed.\033[0m" && return 1; fi
	__zoxide_z "$OLDPWD"
	inspect
	auto_venv
}

function zi() {
	if ! command -v __zoxide_zi &>/dev/null; then printf "\033[1;33mzoxide not installed.\033[0m" && return 1; fi
	__zoxide_zi
	inspect
	auto_venv
}

# cd to pwd from last session. Requires setup in `.zlogout`
function ld() {
	last_pwd_location="$ZDOTDIR/.last_pwd"
	if [[ ! -f "$last_pwd_location" ]]; then
		print "\033[1;33mNo Last PWD available.\033[0m"
		return 1
	fi
	last_pwd=$(cat "$last_pwd_location")
	z "$last_pwd"
}

# copies last command(s)
function lc() {
	num=${1-"1"} # default= 1 -> just last command
	history | tail -n"$num" | cut -c8- | sed 's/"/\"/g' | sed "s/'/\'/g" | sed -E '/^$/d' | pbcopy
	echo "Copied."
}

# copies result of last command(s)
function lr() {
	num=${1-"1"} # default= 1 -> just last command
	last_command=$(history | tail -n"$num" | cut -c 8-)
	echo -n "$(eval "$last_command")" | pbcopy
	echo "Copied."
}
