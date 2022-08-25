# Quick Open File/Folder
# requires: exa, bat, zoxide, fd, fzf
function o (){
	local INPUT="$*"

	if [[ -e "$INPUT" ]] ; then   # skip `fzf` if file is fully named
		[[ -d "$INPUT" ]] && z "$INPUT"
		[[ -f "$INPUT" ]] && open "$INPUT"
		return 0
	fi
	local prev_clipb=$(pbpaste)

	local SELECTED
	SELECTED=$(fd --hidden | fzf \
	           -0 -1 \
	           --query "$INPUT" \
	           --header-first --header="↵ : open/cd   [⇧]↹ : only dirs" \
	           --bind="tab:reload(fd --hidden --type=directory)" \
	           --bind="btab:reload(fd --hidden)" \
	           --preview "if [[ -d {} ]] ; then exa  --icons --oneline {} ; else ; bat --color=always --style=snip --wrap=never --tabs=2 {} ; fi" \
	           )
	if [[ -z "$SELECTED" ]] && [[ "$prev_clipb" == "$(pbpaste)" ]] ; then
		return 0 # abort if no selection
	elif [[ -z "$SELECTED" ]] && [[ "$prev_clipb" != "$(pbpaste)" ]] ; then
		print -z "$(pbpaste)" # write to buffer
	elif [[ -d "$SELECTED" ]] ; then
		z "$SELECTED"
	elif [[ -f "$SELECTED" ]] ; then
		open "$SELECTED"
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
		history | tail -n1 | cut -c8- | pbcopy
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
			*) echo "'$1' cannot be extracted via ex()" ;;
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
