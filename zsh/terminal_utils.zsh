# Quick Open File/Folder
# requires: exa, bat, zoxide, fd, fzf
function o (){
	local selected
	local input="$*"

	if [[ -e "$input" ]] ; then   # skip `fzf` if file is fully named, e.g. through tab completion
		[[ -d "$input" ]] && z "$input"
		[[ -f "$input" ]] && open "$input"
		return 0
	fi
	# --delimiter and --nth options ensure only file name and parent folder are displayed
	selected=$(fd --hidden --color=always | fzf \
					-0 -1 \
					--ansi \
					--query="$input" \
					--expect=ctrl-b \
					--cycle \
					--info=inline \
					--delimiter=/ --with-nth=-2.. --nth=-2.. \
					--header-first \
					--header="↵ : open/cd, ^B: buffer, ↹ : only dirs" \
					--bind="tab:reload(fd --hidden --color=always --type=directory)+change-prompt(↪ )" \
					--preview-window="border-left" \
					--preview 'if [[ -d {} ]] ; then echo "\\033[1;33m"{}"\\033[0m" ; echo ; exa  --icons --oneline {} ; else ; bat --color=always --style=snip --wrap=never --tabs=1 {} ; fi' \
	         )
	[[ -z "$selected" ]] && return 0
	key_pressed=$(echo "$selected" | head -n1)
	selected=$(echo "$selected" | tail -n+2)

	if [[ "$key_pressed" == "ctrl-b" ]] ; then
		print -z "$selected"
	elif [[ -d "$selected" ]] ; then
		z "$selected"
	elif [[ -f "$selected" ]] ; then
		open "$selected"
	fi
}

function directoryInspect (){
	if command git rev-parse --is-inside-work-tree &>/dev/null ; then
		git status --short
		echo
	fi
	if [[ $(ls | wc -l) -lt 20 ]] ; then
		exa
	elif [[ $(ls -d */ | wc -l) -lt 20 ]] ; then
		command exa --all --icons --sort=modified -d */ # only directories
	fi
}

# measure zsh loading time, https://blog.jonlu.ca/posts/speeding-up-zsh
function timezsh(){
	for i in $(seq 1 10); do /usr/bin/time $SHELL -i -c exit; done
}

# Move to trash via Finder (allows retrievability)
# no arg = all files in folder will be deleted
function d () {
	if [[ $# == 0 ]]; then
		IFS=$'\n'
		# shellcheck disable=SC2207
		ALL_FILES=($(find . -not -name ".*"))
		unset IFS
	else
		ALL_FILES=( "$@" ) # save as array
	fi
	for ARG in "${ALL_FILES[@]}"; do
		ABSOLUTE_PATH="$(cd "$(dirname "$ARG")" || return 1; pwd -P)/$(basename "$ARG")"
		osascript -e "
			set toDelete to \"$ABSOLUTE_PATH\" as POSIX file
			tell application \"Finder\" to delete toDelete
		" >/dev/null
	done
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

# smarter z/cd
# (also alternative to https://blog.meain.io/2019/automatically-ls-after-cd/)
eval "$(zoxide init --no-cmd zsh)" # needs to be placed after compinit
function z () {
	if [[ -f  "$1" ]] ; then
		__zoxide_z "$(dirname "$1")"
	else
		__zoxide_z "$1"
	fi
	[[ $? -eq 0 ]] && directoryInspect
}
function zi () {
	__zoxide_zi
	directoryInspect
}

# settings (zshrc)
alias ,="settings"
function settings () {
	( cd "$DOTFILE_FOLDER/zsh" || return
	# shellcheck disable=SC1009,SC1056,SC1073,SC2035
	SELECTED=$( { ls *.zsh | cut -d. -f1 ; ls .z* } | fzf \
	           -0 -1 \
	           --query "$*" \
	           --height=75% \
	           --layout=reverse \
	           --info=hidden \
	           )
	if [[ -n $SELECTED ]] ; then
		[[ $SELECTED != .z* ]] && SELECTED="$SELECTED.zsh"
		open "$SELECTED"
	fi )
}

# copies path of file
function p () {
	# shellcheck disable=SC2164
	ABSOLUTE_PATH="$(cd "$(dirname "$1")"; pwd -P)/$(basename "$1")"
	echo "$ABSOLUTE_PATH" | pbcopy
	echo "Copied: ""$ABSOLUTE_PATH"
}

# copies last n commands
function lc (){
	number="$*"
	if [[ "$number" == "" ]] ; then
		history | tail -n1 | cut -c8- | xargs echo -n | pbcopy
	else
		history | tail -n"$number" | cut -c8- | pbcopy
	fi
	echo "Copied."
}

# Save last n commands to Drafts
function lcd (){
	number="$*"
	if [[ "$number" == "" ]] ; then
		number=1
	fi
	lastCommand=$(history | tail -n "$number" | cut -c 8-)
	osascript -e "tell application \"Drafts\" to make new draft with properties {content: \"$lastCommand\", tags: {\"Terminal Command\"}}" &> /dev/null
}

# copies result of last command
function lr (){
	last_command=$(history | tail -n 1 | cut -c 8-)
	echo -n "$(eval "$last_command")" | pbcopy
	echo "Copied."
}

# extract function
function ex () {
	if [[ -f $1 ]] ; then
		case $1 in
			*.tar.bz2)   tar -xjf "$1"   ;;
			*.tar.gz)    tar -xzf "$1"   ;;
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
	echo "appid: $id"
	echo "$id" | pbcopy
}
