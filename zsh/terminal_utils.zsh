# Quick Open File/Folder
function o() {
	if ! command -v fzf &>/dev/null; then echo "fzf not installed." && return 1; fi
	if ! command -v fd &>/dev/null; then echo "fd not installed." && return 1; fi

	local selected
	local input="$*"

	# skip `fzf` if file is fully named, e.g. through tab completion
	if [[ -f "$input" ]]; then
		open "$input"
		return 0
	fi

	# --delimiter and --nth options ensure only file name and parent folder are displayed
	selected=$(
		fd --type=file --type=symlink --hidden --color=always | fzf \
			-0 -1 \
			--ansi \
			--query="$input" \
			--info=inline \
			--preview 'bat --color=always --style=snip --wrap=never --tabs=2 {}'
	)
	if [[ -z "$selected" ]]; then # fzf aborted
		return 0
	elif [[ -f "$selected" ]]; then
		open "$selected"
	else
		return 1
	fi
}

# show files + git status + brief git log
function inspect() {
	[[ $(tput lines) -gt 20 ]] || return 0 # don't use in embedded terminals, since too small
	if ! command -v exa &>/dev/null; then printf "\033[1;33mexa not installed.\033[0m" && return 1; fi
	if ! command -v git &>/dev/null; then printf "\033[1;33mgit not installed.\033[0m" && return 1; fi

	if git rev-parse --is-inside-work-tree &>/dev/null; then
		gitlog 5 # custom function defined in git_github.zsh
		separator
		if [[ -n "$(git status --short --porcelain)" ]]; then
			git status --short # run again for color
			separator
		fi
	fi
	if [[ $(find . -maxdepth 1 | wc -l) -lt 40 ]]; then
		exa --all --icons --sort=name --group-directories-first \
			--git-ignore --ignore-glob=.DS_Store
	fi
	echo
}

# measure rc loading time, https://blog.jonlu.ca/posts/speeding-up-zsh
function timerc() {
	if command -v hyperfine &>/dev/null; then
		hyperfine "$SHELL -i -c exit"
	else
		time $SHELL -i -c exit
	fi
}

# no arg = all files in folder will be deleted
function d() {
	if [[ $# == 0 ]]; then
		command mv -iv ./* ~/.Trash/
	else
		command mv -iv "$@" ~/.Trash/
	fi
	# shellcheck disable=2181
	# run in background to avoid delay; run in subshell to suppress output
	[[ $? -eq 0 ]] && (afplay "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/dock/drag to trash.aif" &)
}

# go up and delete current dir
function ..d() {
	local current_dir="$PWD"
	cd ..
	local trash_location
	trash_location="$HOME/.Trash/$(basename "$current_dir")"
	[[ -e "$trash_location" ]] && rm -rf "$trash_location" 
	command mv -v "$current_dir" "$trash_location"
	# shellcheck disable=2181
	[[ $? -eq 0 ]] && (afplay "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/dock/drag to trash.aif" &)
}

# draws a separator line with terminal width
function separator() {
	local sep=""
	terminal_width=$(tput cols)
	for ((i = 0; i < terminal_width; i++)); do
		sep="$sep─"
	done
	echo "$sep"
}

# smarter z/cd
# after entering new folder, inspect it (exa, git log, git status, etc.)
function z() {
	if ! command -v __zoxide_z &>/dev/null; then printf "\033[1;33mzoxide not installed.\033[0m" && return 1; fi
	__zoxide_z "$1"
	inspect
}

function zi() {
	if ! command -v __zoxide_zi &>/dev/null; then printf "\033[1;33mzoxide not installed.\033[0m" && return 1; fi
	__zoxide_zi
	inspect
}

# cd to pwd from last session. Requires setup in `.zlogout`
function ld() {
	last_pwd_location="$DOTFILE_FOLDER/zsh/.last_pwd"
	if [[ ! -f "$last_pwd_location" ]]; then
		print "\033[1;33mNo Last PWD available."
		return 1
	fi
	last_pwd=$(cat "$DOTFILE_FOLDER/zsh/.last_pwd")
	__zoxide_z "$last_pwd"
	inspect
}

# select an external volume to eject
alias e="eject"
function eject() {
	volumes=$(df -h | grep -io "\s/Volumes/.*" | cut -c2-)
	if [[ -z "$volumes" ]]; then
		print "\033[1;33mNo volume connected.\033[0m"
		return 1
	fi
	if ! command -v fzf &>/dev/null; then echo "fzf not installed." && return 1; fi
	# if one volume, will auto-eject due to `-1`
	selected=$(echo "$volumes" | fzf -0 -1 --no-info --height=30%)
	[[ -z "$selected" ]] && return 0 # fzf aborted
	diskutil eject "$selected"
}

# copies [l]ast [c]ommand(s)
function lc() {
	num=${1-"1"} # default= 1 -> just last command
	history | tail -n"$num" | cut -c8- | sed 's/"/\"/g' | sed "s/'/\'/g" | sed -E '/^$/d' | pbcopy
	echo "Copied."
}

# copies [r]esult of [l]ast command(s)
function lr() {
	num=${1-"1"} # default= 1 -> just last command
	last_command=$(history | tail -n"$num" | cut -c 8-)
	echo -n "$(eval "$last_command")" | pbcopy
	echo "Copied."
}

# copies [v]iewport
function lv() {
	wezterm cli get-text | pbcopy
	echo "Copied."
}

# extract
function ex() {
	if [[ -f $1 ]]; then
		case $1 in
		*.tar.bz2) tar -xjf "$1" ;;
		*.tar.gz) tar -xzf "$1" ;;
		*.tar.zsr) tar --use-compress-program=unzstd -xvf "$1" ;;
		*.rar) unrar -e "$1" ;;
		*.gz) gunzip "$1" ;;
		*.tar) tar -xf "$1" ;;
		*.tbz2) tar -xjf "$1" ;;
		*.tgz) tar -xzf "$1" ;;
		*.zip) unzip "$1" ;;
		*.Z) uncompress "$1" ;;
		*) echo "'$1' cannot be extracted via ´ex´" ;;
		esac
	else
		echo "'$1' is not a valid file"
	fi
}

# appid of macOS apps
function appid() {
	local id
	id=$(osascript -e "id of app \"$1\"")
	echo "Copied appid: $id"
	echo -n "$id" | pbcopy
}

# Conversions
function yaml2json() {
	file_name=${1%.*} # remove ext. (not using `basename` since it could be yml or yaml)
	# using `explode` to expand anchors & aliases
	# https://mikefarah.gitbook.io/yq/operators/anchor-and-alias-operators#explode-alias-and-anchor
	yq --output-format=json 'explode(.)' "$1" >"${file_name}.json"
}

function json2yaml() {
	file_name=$(basename "$1" .json)
	yq --output-format=yaml '.' "$1" >"$file_name.yaml"
}
