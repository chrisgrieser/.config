# Quick Open File
function o() {
	# skip `fzf` if file is fully named, e.g. through tab completion
	if [[ -f "$1" ]]; then
		open "$1"
		return 0
	fi

	# reloads one ctrl-h (`--bind=ctrl-h`) or as soon as there is no result found (`--bind=zero`)
	local color=$'s|([^/+]*)(/)|\e[0;36m\\1\e[0;33m\\2\e[0m|g'
	local reload="reload($FZF_DEFAULT_COMMAND --hidden --no-ignore --no-ignore-files \
		--glob='!/.git/' --glob='!node_modules' --glob='!.DS_Store' | sed -Ee '$color')"

	local selected
	selected=$(
		# shellcheck disable=2016
		zsh -c "$FZF_DEFAULT_COMMAND" | sed -Ee "$color" |
			fzf --select-1 --ansi --query="$*" --info=inline --header-first \
				--header="^H: --hidden" --bind="ctrl-h:$reload" \
				--keep-right --scheme=path --tiebreak=length,end \
				--delimiter="/" --with-nth=-2.. --nth=-2.. \
				--bind="zero:$reload" \
				--preview-window="55%" \
				--preview '[[ $(file --mime {}) =~ text ]] && bat --color=always --wrap=never --style=header-filesize,header-filename,grid {} || file {} | fold -w $FZF_PREVIEW_COLUMNS' \
				--height="100%"
		# height of 100% required for wezterm's `pane:is_alt_screen_active()`
	)
	[[ -z "$selected" ]] && return 0
	open "$selected"
}

# open last changed file in cwd
function oo {
	local last_modified
	last_modified=$(find . -type file -maxdepth 4 -not -path "./.git/**" -print0 |
		xargs -0 stat -f "%m %N" |
		sort --numeric --reverse |
		sed -n "1p" |
		cut -d" " -f2-)
	open "$last_modified"
}

# completions for it
_o() {
	local -a paths=()
	local -a names=()
	while IFS='' read -r file; do # turn lines into array
		paths+=("$file")
		names+=("$(basename "$file")")
	done < <(zsh -c "$FZF_DEFAULT_COMMAND --max-depth=3")

	local expl && _description -V files-in-pwd expl 'Files in PWD'
	compadd "${expl[@]}" -d names -a paths
}
compdef _o o

#───────────────────────────────────────────────────────────────────────────────

# file finder
# `fd` replacement using just `rg`
function fd {
	rg --no-config --files --binary --ignore-file="$HOME/.config/ripgrep/ignore" |
		rg --color=always "$1"
}

#───────────────────────────────────────────────────────────────────────────────

# search pwd via `rg`, open selection in the editor at the line
function s {
	local selected file line
	selected=$(
		rg "$*" --color=always --colors=path:fg:blue --no-messages --line-number --trim \
			--no-config --smart-case --ignore-file="$HOME/.config/ripgrep/ignore" |
			fzf --ansi --select-1 --delimiter=":" \
				--preview="bat {1} --no-config --color=always --highlight-line={2} --line-range={2}: " \
				--preview-window="60%,top,border-down" \
				--height="100%" # required for for wezterm's `pane:is_alt_screen_active()`
	)
	[[ -z "$selected" ]] && return 0
	file=$(echo "$selected" | cut -d: -f1)
	echo "🖨️ file: $file" >&2
	line=$(echo "$selected" | cut -d: -f2)
	echo "🖨️ line: $line" >&2

	# not opening via `neovide` cli, PENDING https://github.com/neovide/neovide/issues/1586
	open "$file"
	nvim --server "/tmp/nvim_server.pipe" --remote-send "<cmd>$((line + 1))<CR>"
}

#───────────────────────────────────────────────────────────────────────────────

# SEARCH AND REPLACE VIA `rg`
# usage: sr "search" "replace" file1 file2 file3
# DOCS "https://docs.rs/regex/1.*/regex/#syntax"
function sr {
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
		rg --no-config "$search" --case-sensitive --replace="$replace" --passthrough \
			--no-line-number "$file" > /tmp/rgpipe &&
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

# copy last e[x]ecuted [r]esult
function xr() {
	to_copy=$(eval "$(history -n -1)")
	print "\e[1;32mCopied:\e[0m $to_copy"
	echo -n "$to_copy" | pbcopy
}

# copy last e[x]ecuted [c]ommand
function xc() {
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
_xc() {
	local -a last_cmds=()
	while IFS='' read -r value; do # turn lines into array
		last_cmds+=("$value")
	done < <(history -rn -10)

	local _values=({1..10})
	local expl && _description -V last-commands expl 'Last Commands'
	compadd "${expl[@]}" -Q -l -d last_cmds -a _values
}
compdef _xc xc

#───────────────────────────────────────────────────────────────────────────────
# TRASH
# requires a `trash` command

# no arg = all files in folder will be deleted
function d {
	if [[ $# == 0 ]]; then
		trash ./*(D) # (D) makes the glob include dotfiles (zsh-specific)
	else
		trash "$@"
	fi
}

# go up and delete current dir
function ..d() {
	# GUARD accidental deletions of folders
	if [[ ! $PWD =~ /Developer ]]; then
		print '\e[0;33mCan only delete in "Developer" folder.\e[0m'
		return 1
	fi

	# INFO `cd .` to trigger cd-hook *after* deletion 
	cd -q .. && trash "$OLDPWD" && cd .
}
