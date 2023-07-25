# HELPER FUNCTION USED BY OTHERS
# draws a separator line with terminal width
function separator() {
	local terminal_width
	local sep=""
	terminal_width=$(tput cols)
	for ((i = 0; i < terminal_width; i++)); do
		sep="$sep─"
	done
	echo "$sep"
}

#───────────────────────────────────────────────────────────────────────────────

# show files + git status + brief git log
function inspect() {
	# config
	local max_gitlog_lines=5
	local max_files_lines=10
	local disabled_below_term_height=20

	# guard clauses
	[[ $(tput lines) -gt $disabled_below_term_height ]] || return 0 # don't use in embedded terminals, since too small
	if ! command -v exa &>/dev/null; then printf "\033[1;33mexa not installed.\033[0m" && return 1; fi
	if ! command -v git &>/dev/null; then printf "\033[1;33mgit not installed.\033[0m" && return 1; fi
	if ! which separator &>/dev/null; then printf "\033[1;33mseperator helper function not defined.\033[0m" && return 1; fi

	# GIT LOG & STATUS
	if git rev-parse --is-inside-work-tree &>/dev/null; then
		gitlog $max_gitlog_lines
		separator
		if [[ -n "$(git status --short --porcelain)" ]]; then
			git status --short # run again for color
			separator
		fi
	fi

	# FILES
	# columns needs to be set, since exa print as --oneline if piped https://github.com/ogham/exa/issues/522
	local exa_output terminal_width
	terminal_width=$(tput cols)
	exa_output=$(export COLUMNS=$terminal_width && exa --all --grid --color=always \
		--icons --git-ignore --ignore-glob=.DS_Store --sort=name --group-directories-first)
	if [[ $(echo "$exa_output" | wc -l) -gt $max_files_lines ]] ; then
		echo "$exa_output" | head -n$max_files_lines
		print "\033[1;34m(…)\033[0m" # blue = exa's default folder color
	else
		[[ -n "$exa_output" ]] && echo "$exa_output"
		echo
	fi
}

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

# safer removal
# - moves to macOS trash instead of irreversibly deleting with `rm`
# - no arg = all files in folder will be deleted
# - adds sound on success
function d() {
	if ! command -v trash &>/dev/null; then print "\033[1;33mmacos-trash not installed.\033[0m" && return 1; fi

	if [[ $# == 0 ]]; then
		trash ./*(D) # (D) makes the glob include dotfiles. is zsh-specific
	else
		trash "$@"
	fi

	## add nicer trash sound
	# shellcheck disable=2181
	[[ $? -ne 0 ]] && return 0
	current_vol=$(osascript -e 'output volume of (get volume settings)')
	vol_percent=$(echo "scale=2 ; $current_vol / 100" | bc) # afplay play with 100% volume by default
	(afplay --volume "$vol_percent" "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/dock/drag to trash.aif" &)
}

# go up and delete current dir
function ..d() {
	if ! command -v trash &>/dev/null; then print "\033[1;33mmacos-trash not installed.\033[0m" && return 1; fi

	local current_dir="$PWD"
	cd ..
	trash "$current_dir"
	inspect

	## add nicer trash sound
	# shellcheck disable=2181
	[[ $? -ne 0 ]] && return 0
	current_vol=$(osascript -e 'output volume of (get volume settings)')
	vol_percent=$(echo "scale=2 ; $current_vol / 100" | bc) # afplay play with 100% volume by default
	(afplay --volume "$vol_percent" "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/dock/drag to trash.aif" &)
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
	if ! command -v wezterm &>/dev/null; then print "\033[1;33mwezterm not installed.\033[0m" && return 1; fi
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
