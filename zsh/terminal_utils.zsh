# Quick Open File
function o() {
	if [[ ! -x "$(command -v fzf)" ]]; then print "\033[1;33mfzf not installed.\033[0m" && return 1; fi
	if [[ ! -x "$(command -v fd)" ]]; then print "\033[1;33mfd not installed.\033[0m" && return 1; fi
	if [[ ! -x "$(command -v eza)" ]]; then print "\033[1;33meza not installed.\033[0m" && return 1; fi
	if [[ ! -x "$(command -v bat)" ]]; then print "\033[1;33mbat not installed.\033[0m" && return 1; fi

	local input="$*"

	# skip `fzf` if file is fully named, e.g. through tab completion
	if [[ -f "$input" ]]; then
		open "$input"
		return 0
	fi

	# --delimiter and --nth options ensure only file name and parent folder are displayed
	local selected
	selected=$(
		# shellcheck disable=2016
		fd --type=file --type=symlink --color=always | fzf \
			-1 --ansi --query="$input" --info=inline --header-first \
			--header="^H: --hidden --no-ignore   ^P: Copy Path   ^N: Copy Name" \
			--with-nth=-2.. --delimiter="/" \
			--bind="ctrl-h:reload(fd --hidden --no-ignore --exclude='/.git/' --exclude='.DS_Store' --type=file --type=symlink --color=always)" \
			--expect="ctrl-p,ctrl-n" \
			--preview-window="55%" \
			--preview '[[ $(file --mime {}) =~ text ]] && bat --color=always --wrap=never --style=header {} || file {} | fold -w $FZF_PREVIEW_COLUMNS' \
			--height="100%" #required for wezterm's pane:is_alt_screen_active()
	)
	[[ -z "$selected" ]] && return 0 # aborted

	key_pressed=$(echo "$selected" | head -n1)
	file_path="$PWD/$(echo "$selected" | sed '1d')"

	if [[ "$key_pressed" == "ctrl-p" || "$key_pressed" == "ctrl-n" ]]; then
		[[ "$key_pressed" == "ctrl-n" ]] && file_path=$(basename "$file_path")
		echo -n "$file_path" | pbcopy
		print "Copied: \"\033[1;34m$file_path\033[0m\""
	else
		open "$file_path"
	fi
}

#───────────────────────────────────────────────────────────────────────────────

# mkdir and cd
function mkcd {
	mkdir -p "$1" && cd "$1" || return 1
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

#───────────────────────────────────────────────────────────────────────────────

# copies last command(s)
function lc() {
	num=${1:-1} # default 1 -> just last command
	history |
		tail -n"$num" |
		cut -c8- |
		sed -e 's/"/\"/g' -e "s/'/\'/g" -Ee '/^$/d' | 
		pbcopy
	echo "Copied."
}

# copies result of last command(s)
function lr() {
	num=${1:-1} # default 1 -> just last command
	last_command=$(history | tail -n"$num" | cut -c8-)
	echo -n "$(eval "$last_command")" | pbcopy
	echo "Copied."
}
