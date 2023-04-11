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
			--cycle \
			--info=inline \
			--preview-window="border-left" \
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

# show files
# + git status (if in git dir)
# + brief git log (if at git root)
function inspect() {
	if ! command -v exa &>/dev/null; then echo "exa not installed." && return 1; fi
	if ! command -v git &>/dev/null; then echo "git not installed." && return 1; fi

	if git rev-parse --is-inside-work-tree &>/dev/null; then
		gitstatus=$(git status --short --porcelain)
		if [[ -n "$gitstatus" ]]; then
			git status --short # run again for color
			separator
		fi
		if [[ $(git rev-parse --show-toplevel) == $(pwd) ]]; then
			git log -n 5 --all --color --graph --pretty=format:'%C(yellow)%h%C(red)%d%C(reset) %s %C(green)(%ch) %C(bold blue)<%an>%C(reset)' | 
				sed -e 's/origin/o/g' |
				sed -e 's/grafted, / :fs /g' 
				" "
			separator
		fi
	fi
	exa --long --all --grid \
		--sort=modified --group-directories-first \
		--icons --git --no-user --no-permissions --no-time --no-filesize \
		--git-ignore --ignore-glob=.git --ignore-glob=.DS_Store
	echo
}

# measure zsh loading time, https://blog.jonlu.ca/posts/speeding-up-zsh
function timezsh() {
	time $SHELL -i -c exit
}

# no arg = all files in folder will be deleted
function d() {
	if [[ $# == 0 ]]; then
		mv -f ./* ~/.Trash/
	else
		mv -f "$@" ~/.Trash/
	fi
	# shellcheck disable=2181
	# run in background to avoid delay; run in subshell to suppress output
	[[ $? -eq 0 ]] && (afplay "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/dock/drag to trash.aif" &)
}

# draws a separator line with terminal width
function separator() {
	local SEP=""
	terminal_width=$(tput cols)
	for ((i = 0; i < terminal_width; i++)); do
		SEP="$SEP─"
	done
	echo "$SEP"
}

# smarter z/cd (alternative to https://blog.meain.io/2019/automatically-ls-after-cd/)
function z() {
	if ! command -v __zoxide_z &>/dev/null; then echo "zoxide not installed." && return 1; fi
	if [[ -f "$1" ]]; then # if a file, go to the file's directory instead of failing
		__zoxide_z "$(dirname "$1")"
	else
		__zoxide_z "$1"
	fi
	# shellcheck disable=2181
	[[ $? -eq 0 ]] && inspect
}

function zi() {
	if ! command -v __zoxide_z &>/dev/null; then echo "zoxide not installed." && return 1; fi
	__zoxide_zi
	inspect
}

# cd to last directory before quitting. Requires setup in `.zlogout`
function ld() {
	last_pwd_location="$DOTFILE_FOLDER/zsh/.last_pwd"
	if [[ ! -f "$last_pwd_location" ]]; then
		print "\033[1;33mNo Last PWD available."
	else
		last_pwd=$(cat "$DOTFILE_FOLDER/zsh/.last_pwd")
		z "$last_pwd"
	fi
}

# select an external volume to eject
function eject() {
	volumes=$(df -h | grep -io "\s/Volumes/.*" | cut -c2-)
	if [[ -z "$volumes" ]]; then
		print "\033[1;33mNo volume connected.\033[0m"
		return 1
	fi

	if ! command -v fzf &>/dev/null; then echo "fzf not installed." && return 1; fi

	# if one volume, will auto-eject due to `-1`
	selected=$(echo "$volumes" | 
		fzf -0 -1 \
			--layout=reverse --bind="tab:down,shift-tab:up" \
			--no-info \
			--height=30%\
	)
	[[ -z "$selected" ]] && return 0 # fzf aborted

	diskutil eject "$selected"
}

# copies [l]ast [c]ommand(s)
function lc() {
	num=${1-"1"} # default= 1 -> last command
	history | tail -n"$num" | cut -c8- | sed 's/"/\"/g' | sed "s/'/\'/g" | sed -E '/^$/d' | pbcopy
	echo "Copied."
}

# save [l]ast [c]ommand(s) in [D]rafts
function lcd() {
	num=${1-"1"} # default: only one (1) last command
	local timestamp
	timestamp="$(date +%Y-%m-%d_%H-%M-%S)"
	local drafts_inbox="$HOME/Library/Mobile Documents/iCloud~com~agiletortoise~Drafts5/Documents/Inbox/"
	mkdir -p "$drafts_inbox"
	history | tail -n"$num" | cut -c8- | sed -E '/^$/d' >"$drafts_inbox/$timestamp.md"
	echo "Saved in Drafts."
}

# copies [r]esult of [l]ast command(s)
function lr() {
	num=${1-"1"} # default: 1 last command
	last_command=$(history | tail -n"$num" | cut -c 8-)
	echo -n "$(eval "$last_command")" | pbcopy
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
	echo "$id" | pbcopy
}

# Conversions
# using `explode` to expand anchors & aliases: https://mikefarah.gitbook.io/yq/operators/anchor-and-alias-operators#explode-alias-and-anchor
function yaml2json() {
	file_name=${1%.*} # remove extension
	yq -o=json 'explode(.)' "$1" >"${file_name}.json"
}

function json2yaml() {
	yq -P '.' "$1" >"$(basename "$1" .json).yml"
}
