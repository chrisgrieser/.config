# LONG ALIASES
alias sizes_in_cwd="du -sh . ./* | sort -rh | sed 's|\./||'"

# mason things only made available, but not loaded directly
alias export_mason_path='export PATH="$HOME/.local/share/nvim/mason/bin":$PATH'

# utility scripts only made available, but not loaded directly (= lazy-loading)
export PATH="$ZDOTDIR/utilities/":$PATH

#───────────────────────────────────────────────────────────────────────────────

function delete_empty_folders {
	find "." -type d -not -path "**/.git/**" -empty
	find "." -type d -not -path "**/.git/**" -empty -delete
}

function delete_DS_Store {
	find "." -name ".DS_Store"
	find "." -name ".DS_Store" -delete
}

function cake {
	mkdir -p "$1" && cd "$1" || return 1
}
function topen {
	touch "$1" && open "$1"
}

# colorized & paginated tree, $1 = level
function tree {
	local level=${1:-3}
	eza --tree --level="$level" --no-quotes --color=always | less
}

function p {
	qlmanage -p "$1" &> /dev/null
}

function line_count() {
	where=${1:-"."}
	find -E "$where" -type file \
		-not -path "./tests/**" \
		-not -path "./.git/**" -not -path "./node_modules/**" -not -path "./doc/**" \
		-not -path "**/__pycache__/**" -not -path "./.venv/**" -not -name ".DS_Store" \
		-not -name "LICENSE" -not -iregex ".*\.(webp|png|svg|jpe?g|json|ya?ml|md|toml|editorconfig)$" \
		-print0 | xargs -0 wc -l
}

#───────────────────────────────────────────────────────────────────────────────

# On empty buffer, `esc` starts file opener
# - cannot trigger this on `space`, since it messes with `zsh-syntax-highlighting`
# - uses `rg` to sort files by recency
_escape_on_empty_buffer() {
	if [[ -n "$BUFFER" || "$CONTEXT" != "start" ]]; then
		zle vi-cmd-mode # exit insert mode
		return
	fi

	local selected
	## no need for `--sortr=modified`, since using `eza --sort=oldest` afterwards
	local rg_cmd="rg --no-config --files --ignore-file='$HOME/.config/ripgrep/ignore'"

	selected=$(
		zsh -c "$rg_cmd" |
			eza --stdin --color=always --icons=always --sort=oldest |
			fzf --ansi --multi \
				--info=inline --height="50%" \
				--header="^H: --hidden" --scheme=path --tiebreak=length,end \
				--bind="ctrl-h:change-header(including hidden files)+reload($rg_cmd \
					--hidden --no-ignore --no-ignore-files \
					--glob='!/.git/' --glob='!node_modules' --glob='!__pycache__' --glob='!.DS_Store' |
					eza --stdin --color=always --icons=always --sort=oldest)"
	)
	zle reset-prompt
	[[ -z "$selected" ]] && return 0

	echo "$selected" | cut -c3- | xargs open # `cut` to remove the nerdfont icons
}
zle -N _escape_on_empty_buffer
bindkey '\e' _escape_on_empty_buffer

#───────────────────────────────────────────────────────────────────────────────

# search pwd via `rg`, open selection in the editor at the line
function s {
	local selected file line
	selected=$(
		rg "$*" --color=always --no-messages --line-number --trim --no-config \
			--hidden --smart-case --sortr=modified --ignore-file="$HOME/.config/ripgrep/ignore" |
			fzf --ansi --select-1 --delimiter=":" \
				--preview="bat {1} --no-config --color=always --highlight-line={2} --line-range={2}: " \
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

# copy [l]ast [c]ommand # typos: ignore-line
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

# copy result of last command
function lr() {
	to_copy=$(eval "$(history -n -1)")
	print "\e[1;32mCopied:\e[0m $to_copy"
	echo -n "$to_copy" | pbcopy
}

#───────────────────────────────────────────────────────────────────────────────
# TRASH
# requires a `trash` command

# no arg = all files in folder will be trashed
function d {
	if [[ $# == 0 ]]; then
		trash ./*(D) # (D) makes the glob include dotfiles (zsh-specific)
	else
		trash "$@"
	fi
}

# go up and delete current dir
function ..d() {
	# GUARD
	if [[ ! "$PWD" =~ /Developer/ ]]; then
		print '\e[0;33mCan only delete inside subfolder of "~/Developer".\e[0m'
		return 1
	elif [[ -n $(git log --branches --not --remotes) ]]; then
		print '\e[0;33mRepo has unpushed commits.\e[0m'
		return 1
	fi

	# disable venv
	if [[ -n "$VIRTUAL_ENV" && -z "$venv_path" ]]; then
		deactivate
		echo && inspect_venv
	fi

	# INFO `cd .` to trigger cd-hook *after* deletion
	cd -q .. && trash "$OLDPWD" && cd .
}

#───────────────────────────────────────────────────────────────────────────────

# interactive `jq`
function ij {
	# Read stdin into a temp file if data is provided via stdin
	if ! [[ -t 0 ]]; then
		file="$(mktemp)"
		trap 'rm -f "$file"' EXIT
		cat > "$file"
	else
		file="$1"
	fi

	final_query=$(
		jq --raw-output ". |keys[]" "$file" | fzf \
			--query="." --prompt="jq > " --no-info --disabled \
			--bind="enter:transform-query(echo {q}.{+} | sed -Ee 's/\.([[:digit:]])$/[\1]/' -e 's/\.\././g' )" \
			--bind="change:reload(jq --raw-output {q}'|keys[]' '$file')" \
			--bind="esc:cancel" \
			--height="100%" --preview-window="60%" \
			--preview="jq --color-output {q} '$file'"
	)
	[[ -z "$final_query" ]] && return 0
	echo -n "$final_query" | pbcopy
	print "\e[1;32mQuery copied:\e[0m $final_query"
}

#───────────────────────────────────────────────────────────────────────────────

# check website online status
function watch_website {
	local url=$1
	local http_status
	http_status=$(curl --silent --location --output /dev/null --write-out "%{http_code}" "$url")
	if [[ "$http_status" -eq 200 ]]; then
		echo "🌐 $url is online again"
		"$ZDOTDIR/notificator" --title "🌐 $url" --message "online again" --sound "Blow"
	else
		echo "HTTP code: $http_status"
		return 1
	fi
}
