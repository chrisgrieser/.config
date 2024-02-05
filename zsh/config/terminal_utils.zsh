# Quick Open File
function o() {
	local input="$*"

	# skip `fzf` if file is fully named, e.g. through tab completion
	if [[ -f "$input" ]]; then
		open "$input"
		return 0
	fi

	# `--delimiter="/" --nth=-1` ensures only the filename is searched
	# PENDING https://github.com/junegunn/fzf/issues/3608
	local selected
	selected=$(
		# shellcheck disable=2016
		fd --type=file --type=symlink --color=always | fzf \
			--select-1 --ansi --query="$input" --info=inline --header-first \
			--header="^H: --hidden  ^P: Copy Path  ^N: Copy Name  ^D: Goto Parent" \
			--keep-right \
			--scheme=path --tiebreak=length,end \
			--delimiter="/" --with-nth=-2.. --nth=-2.. \
			--bind="ctrl-h:reload(fd --hidden --no-ignore --exclude='/.git/' --exclude='.DS_Store' --type=file --type=symlink --color=always)" \
			--expect="ctrl-p,ctrl-n,ctrl-d" \
			--preview-window="55%" \
			--preview '[[ $(file --mime {}) =~ text ]] && bat --color=always --wrap=never --style=header-filesize,header-filename,grid {} || file {} | fold -w $FZF_PREVIEW_COLUMNS' \
			--height="100%" #required for wezterm's `pane:is_alt_screen_active()`
	)
	[[ -z "$selected" ]] && return 0 # aborted

	key_pressed=$(echo "$selected" | head -n1)
	file_path="$PWD/$(echo "$selected" | sed '1d')"

	if [[ "$key_pressed" == "ctrl-d" ]]; then
		parent_dir=$(dirname "$file_path")
		cd "$parent_dir" || return 1
	elif [[ "$key_pressed" == "ctrl-p" || "$key_pressed" == "ctrl-n" ]]; then
		[[ "$key_pressed" == "ctrl-n" ]] && file_path=$(basename "$file_path")
		echo -n "$file_path" | pbcopy
		print "\e[1;32mCopied:\e[0m $file_path"
	else
		open "$file_path"
	fi
}

# nicer & explorable tree view
function _tree {
	eza --tree --level="$1" --color=always --icons=always --git-ignore \
		--no-quotes --hyperlink |
		sed '1d' | less
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
	"json" | "yml" | "yaml")
		jless "$file"
		;;
	"pdf" | "html")
		qlmanage -p "$file"
		;;
	"gif" | "png" | "jpg" | "jpeg" | "webp" | "tiff")
		image_viewer=$([[ "$TERM_PROGRAM" == "WezTerm" ]] && echo "wezterm imgcat" || echo "qlmanage -p")
		$image_viewer "$file"
		;;
	*)
		bat "$file"
		;;
	esac
}

#───────────────────────────────────────────────────────────────────────────────

# copy result of last command
function lr() {
	to_copy=$(eval "$(history -n -1)")
	print "\e[1;32mCopied:\e[0m $to_copy"
	echo -n "$to_copy" | pbcopy
}

# copy last command(s)
function lc() {
	local to_copy cmd
	if [[ $# -gt 0 ]]; then
		to_copy=""
		for arg in "$@"; do
			cmd=$(history -n -"$arg" -"$arg")
			to_copy="$to_copy\n$cmd"
		done
		to_copy=$(echo -n "$to_copy" | grep -v "^$")
	else
		to_copy=$(history -n -1)
	fi
	print "\e[1;32mCopied:\e[0m"
	echo -n "$to_copy"
	echo -n "$to_copy" | pbcopy
}

# completions for it
_lc() {
	# turn lines into array
	local -a _last_cmds=()
	while IFS='' read -r value; do
		_last_cmds+=("$value")
	done < <(history -rn -10)

	local _values=({1..10})
	local expl && _description -V last-commands expl 'Last Commands'
	compadd "${expl[@]}" -Q -l -d _last_cmds -a _values
}
compdef _lc lc
