# Quick Open File/Folder
function o (){
	if ! command -v fzf &>/dev/null; then echo "fzf not installed." && exit 1; fi
	if ! command -v fd &>/dev/null; then echo "fd not installed." && exit 1; fi
	if ! command -v __zoxide_z &>/dev/null; then echo "zoxide not installed." && exit 1; fi

	local selected
	local input="$*"

	# skip `fzf` if file is fully named, e.g. through tab completion
	if [[ -d "$input" ]] ; then 
		z "$input"
		return 0
	elif [[ -f "$input" ]] ; then 
		open "$input"
		return 0
	fi

	# --delimiter and --nth options ensure only file name and parent folder are displayed
	selected=$(fd --hidden --color=always | fzf \
					-0 -1 \
					--ansi \
					--query="$input" \
					--cycle \
					--info=inline \
					--delimiter=/ --with-nth=-2.. --nth=-2.. \
					--header-first \
					--header="↵  :open/cd, ↹ : only dirs, ⇧↹ : depth=1" \
					--bind="tab:reload(fd --hidden --color=always --type=directory)+change-prompt(↪ )" \
					--bind="shift-tab:reload(fd --hidden --color=always --max-depth=1)" \
					--preview-window="border-left" \
					--preview 'if [[ -d {} ]] ; then echo "\\033[1;33m"{}"\\033[0m" ; echo ; exa  --icons --oneline {} ; else ; bat --color=always --style=snip --wrap=never --tabs=1 {} ; fi' \
				)
	if [[ -z "$selected" ]] ; then  # fzf aborted
		return 0
	elif [[ -d "$selected" ]] ; then
		z "$selected"
	elif [[ -f "$selected" ]] ; then
		open "$selected"
	else
		return 1
	fi
}

function directoryInspect (){
	if ! command -v exa &>/dev/null; then echo "exa not installed." && exit 1; fi
	
	if command git --no-optional-locks rev-parse --is-inside-work-tree &>/dev/null ; then
		git --no-optional-locks status --short
		echo
	fi
	# shellcheck disable=2012
	if [[ $(ls | wc -l) -lt 20 ]] ; then
		exa
	fi
}

alias bkp='zsh "$DOTFILE_FOLDER/utility-scripts/backup-script.sh"'

# measure zsh loading time, https://blog.jonlu.ca/posts/speeding-up-zsh
function timezsh(){
	time $SHELL -i -c exit
}

# no arg = all files in folder will be deleted
function d () {
	if ! command -v trash &>/dev/null; then echo "trash-cli not installed." && exit 1; fi
	if [[ $# == 0 ]]; then
		trash --trash-dir="$HOME/.Trash" ./*
	else
		trash --trash-dir="$HOME/.Trash" "$@"
	fi
}

# draws a separator line with terminal width
function separator (){
	local SEP=""
	terminal_width=$(tput cols)
	for (( i = 0; i < terminal_width; i++ )); do
		SEP="$SEP─"
	done
	echo "$SEP"
}

# smarter z/cd (alternative to https://blog.meain.io/2019/automatically-ls-after-cd/)

function z () {
	if ! command -v __zoxide_z &>/dev/null; then echo "zoxide not installed." && exit 1; fi
	if [[ -f "$1" ]] ; then
		__zoxide_z "$(dirname "$1")"
	else
		__zoxide_z "$1"
	fi
	# shellcheck disable=2181
	[[ $? -eq 0 ]] && directoryInspect
}
function zi () {
	if ! command -v __zoxide_z &>/dev/null; then echo "zoxide not installed." && exit 1; fi
	__zoxide_zi
	directoryInspect
}

# copies last command(s)
function lc (){
	num=${1-"1"} # default= 1 -> last command
	history | tail -n"$num" | cut -c8- | sed 's/"/\"/g' | sed "s/'/\'/g" | sed -E '/^$/d'| pbcopy
	echo "Copied."
}
# save last command(s) in Drafts
function lcd (){
	num=${1-"1"} # default: 1 last command
	local timestamp
	timestamp="$(date +%Y-%m-%d_%H-%M-%S)"
	local drafts_inbox="$HOME/Library/Mobile Documents/iCloud~com~agiletortoise~Drafts5/Documents/Inbox/"
	mkdir -p "$drafts_inbox"
	history | tail -n"$num" | cut -c8- | sed -E '/^$/d' > "$drafts_inbox/$timestamp.md"
	echo "Saved in Drafts."
}

# copies result of last command(s)
function lr (){
	num=${1-"1"} # default: 1 last command
	last_command=$(history | tail -n"$num" | cut -c 8-)
	echo -n "$(eval "$last_command")" | pbcopy
	echo "Copied."
}

# extract
function ex () {
	if [[ -f $1 ]] ; then
		case $1 in
			*.tar.bz2)   tar -xjf "$1"   ;;
			*.tar.gz)    tar -xzf "$1"   ;;
			*.tar.zsr)    tar --use-compress-program=unzstd -xvf "$1" ;;
			*.rar)       unrar -e "$1"   ;;
			*.gz)        gunzip "$1"     ;;
			*.tar)       tar -xf "$1"    ;;
			*.tbz2)      tar -xjf "$1"   ;;
			*.tgz)       tar -xzf "$1"   ;;
			*.zip)       unzip "$1"      ;;
			*.Z)         uncompress "$1" ;;
			*) echo "'$1' cannot be extracted via ´ex´" ;;
		esac
	else
		echo "'$1' is not a valid file"
	fi
}

# appid of macOS apps
function appid () {
	local id
	id=$(osascript -e "id of app \"$1\"")
	echo "Copid appid: $id"
	echo "$id" | pbcopy
}

# Conversions
# using `explode` to expand anchors & aliases: https://mikefarah.gitbook.io/yq/operators/anchor-and-alias-operators#explode-alias-and-anchor
function yaml2json () {
	file_name=${1%.*} # remove extension
	yq -o=json 'explode(.)' "$1" > "${file_name}.json"
}

function json2yaml () {
	yq -P '.' "$1" > "$(basename "$1" .json).yml"
}
