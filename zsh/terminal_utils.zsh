# Quick Open File
function o() {
	if [[ ! -x "$(command -v fzf)" ]]; then print "\033[1;33mfzf not installed.\033[0m" && return 1; fi
	if [[ ! -x "$(command -v fd)" ]]; then print "\033[1;33mfd not installed.\033[0m" && return 1; fi
	if [[ ! -x "$(command -v eza)" ]]; then print "\033[1;33meza not installed.\033[0m" && return 1; fi
	if [[ ! "$(command -v bat)" ]]; then print "\033[1;33mbat not installed.\033[0m" && return 1; fi

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
			--select-1 --ansi --query="$input" --info=inline --header-first \
			--header="^H: --hidden --no-ignore   ^P: Copy Path   ^N: Copy Name" \
			--keep-right \
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
		print "Copied: \033[1;36m$file_path\033[0m"
	else
		open "$file_path"
	fi
}

# nicer & more interactive tree
function _tree {
	if [[ ! -x "$(command -v eza)" ]]; then print "\e[1;33meza not installed.\e[0m" && return 1; fi
	if [[ ! -x "$(command -v fzf)" ]]; then print "\e[1;33mfzf not installed.\e[0m" && return 1; fi

	eza --tree --level="$1" --color=always --icons=always --git-ignore --no-quotes |
		sed '1d' | # remove `.`
		fzf --ansi --no-sort --track
}
alias tree='_tree 2'
alias treee='_tree 3'
alias treeee='_tree 4'

#───────────────────────────────────────────────────────────────────────────────

# previewer
function p {
	file="$1"
	ext=${file##*.}
	case $ext in
	"yml" | "yaml")
		yq "." "$file"
		;;
	"json")
		command jless --no-line-numbers "$file"
		;;
	"pdf")
		qlmanage -p "$file"
		;;
	"gif" | "png" | "jpg" | "jpeg" | "webp" | "tiff")
		[[ "$TERM_PROGRAM" == "WezTerm" ]] && image_viewer="wezterm imgcat" || image_viewer="qlmanage -p"
		$image_viewer "$file"
		;;
	*)
		bat "$file"
		;;
	esac
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
