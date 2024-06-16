# Quick Open File
function o() {
	# skip `fzf` if file is fully named, e.g. through tab completion
	if [[ -f "$1" ]]; then
		open "$1"
		return 0
	fi

	# reloads one ctrl-h (`--bind=ctrl-h`) or as soon as there is no result found (`--bind=zero`)
	local reload="reload(fd --hidden --no-ignore --exclude='/.git/' --exclude='node_modules' --exclude='.DS_Store' --type=file --type=symlink --color=always)"

	local selected
	selected=$(
		# shellcheck disable=2016
		"$FZF_DEFAULT_COMMAND" --color=always | fzf \
			--select-1 --ansi --query="$*" --info=inline --header-first \
			--header="^H: --hidden  ^P: Copy Path  ^N: Copy Name  ^D: Goto Parent" \
			--keep-right --scheme=path --tiebreak=length,end \
			--delimiter="/" --with-nth=-2.. --nth=-2.. \
			--bind="ctrl-h:$reload" --bind="zero:$reload" \
			--expect="ctrl-p,ctrl-n,ctrl-d" \
			--preview-window="55%" \
			--preview '[[ $(file --mime {}) =~ text ]] && bat --color=always --wrap=never --style=header-filesize,header-filename,grid {} || file {} | fold -w $FZF_PREVIEW_COLUMNS' \
			--height="100%"
		# height of 100% required for wezterm's `pane:is_alt_screen_active()`
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

# completions for it
_o() {
	local -a paths=()
	local -a names=()
	while IFS='' read -r file; do # turn lines into array
		paths+=("$file")
		names+=("$(basename "$file")")
	done < <(fd --max-depth=3 --type=file --type=symlink)

	local expl && _description -V files-in-pwd expl 'Files in PWD'
	compadd "${expl[@]}" -d names -a paths
}
compdef _o o

#───────────────────────────────────────────────────────────────────────────────

# search pwd via `rg`, open selection in the editor at the line
function s {
	local selected file line
	selected=$(
		rg "$*" --color=always --colors=path:fg:blue --no-messages --line-number --trim \
			--no-config --smart-case --ignore-file="$HOME/.config/rg/ignore" |
			fzf --ansi --select-1 \
				--delimiter=":" --nth=1 --with-nth=1,2 \
				--preview='bat {1} --color=always --style=header,numbers --highlight-line={2} --line-range={2}: ' \
				--preview-window="60%,top,border-down" \
				--height="100%" # required for for wezterm's `pane:is_alt_screen_active()`
	)
	[[ -z "$selected" ]] && return 0
	file=$(echo "$selected" | cut -d: -f1)
	line=$(echo "$selected" | cut -d: -f2)

	# not opening via `neovide` cli, PENDING https://github.com/neovide/neovide/issues/1586
	open "$file"
	nvim --server "/tmp/nvim_server.pipe" --remote-send "<cmd>$((line + 1))<CR>"
}

#───────────────────────────────────────────────────────────────────────────────

# SEARCH AND REPLACE VIA `rg`
# usage: sr "search" "replace" file1 file2 file3
function sr {
	if [[ "$1" == "-h" || "$1" == "--help" ]]; then
		open "https://docs.rs/regex/1.*/regex/#syntax"
		return 0
	fi

	local search="$1"
	local replace
	# HACK deal with annoying named capture groups (see `man rg` on `--replace`)
	# shellcheck disable=2001
	replace=$(echo "$2" | sed 's/\$\([[:digit:]]\)/${\1}/g')
	shift 2

	local files
	files=$(rg "$search" --files-with-matches --case-sensitive --no-config "$@")
	[[ -z "$files" ]] && return 1

	echo "$files" | while read -r file; do
		rg "$search" --pcre2 --case-sensitive --replace="$replace" --passthrough \
			--no-line-number --no-config "$file" > /tmp/rgpipe &&
			mv /tmp/rgpipe "$file"
	done
}

#───────────────────────────────────────────────────────────────────────────────
# fzf history search
# simplified version of https://github.com/junegunn/fzf/blob/master/shell/key-bindings.zsh

function hs() {
	local selected item key_pressed
	selected=$(
		fc -rl 1 | cut -c8- | bat --color=always --theme=ansi --language=zsh |
			fzf --ansi --multi --query="$1" --scheme=history \
				--bind="change:first" \
				--height=50% --info=inline \
				--expect="ctrl-y" --header-first --header="↵ : Put into buffer    ^Y: Copy"
	)
	[[ -z "$selected" ]] && return 0
	key_pressed=$(echo "$selected" | head -n1)
	item="$(echo "$selected" | tail -n1)"

	if [[ "$key_pressed" == "ctrl-y" ]]; then
		echo -n "$item" | pbcopy
		print "\e[1;32mCopied:\e[0m $item"
	else
		print -z "$item"
	fi
}

#───────────────────────────────────────────────────────────────────────────────

# file previewer
function p {
	local filetype_info
	filetype_info=$(file --mime "$1")
	if [[ "$filetype_info" =~ json ]]; then
		fx "$1"
	elif [[ "$filetype_info" =~ text ]]; then
		bat "$1"
	elif [[ "$filetype_info" =~ image ]]; then
		qlmanage -p "$1" &> /dev/null
	else
		file "$1"
	fi
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
	local -a last_cmds=()
	while IFS='' read -r value; do # turn lines into array
		last_cmds+=("$value")
	done < <(history -rn -10)

	local _values=({1..10})
	local expl && _description -V last-commands expl 'Last Commands'
	compadd "${expl[@]}" -Q -l -d last_cmds -a _values
}
compdef _lc lc
