function directoryInspect (){
	command git rev-parse --is-inside-work-tree &>/dev/null && git status --short
	if [[ $(ls | wc -l) -gt 0 ]] && [[ $(ls | wc -l) -lt 30 ]] ; then
		exa
		echo
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

# Quick Open File
# (or change directory if a folder is selected)
function o (){
	local INPUT="$*"

	# skip `fzf` if file is fully named (e.g. through tab-completion)
	[[ -f "$INPUT" ]] && { open "$INPUT" ; return }
	[[ -d "$INPUT" ]] && { z "$INPUT" ; runMagicEnter ; return }

	local SELECTED
	SELECTED=$(fd --hidden | fzf \
	           -0 -1 \
	           --query "$INPUT" \
	           --preview "if [[ -d {} ]] ; then exa ; else ; bat --color=always --style=snip --wrap=character --tabs=2 --line-range=:\$FZF_PREVIEW_LINES --terminal-width=\$FZF_PREVIEW_COLUMNS {} ; fi" \
	           )
	[[ -z "$SELECTED" ]] && return 130 # abort if no selection

	if [[ -d "$SELECTED" ]] ; then
		z "$SELECTED"
	else
		open "$SELECTED"
	fi
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
	directoryInspect
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
	if [[ $SELECTED != "" ]] ; then
		[[ $SELECTED != .z* ]] && SELECTED="$SELECTED.zsh"
		open "$SELECTED"
	fi )
}

# Make directory and cd there
function mkcd () {
	mkdir -p "$1"
	cd "$1" || return 1
}

# get path of file
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
		echo -n "$(history | tail -n 1 | cut -c 8-)" | pbcopy
	else
		history | tail -n "$number" | cut -c 8- | pbcopy
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
ex () {
	if [[ -f $1 ]] ; then
		case $1 in
			*.tar.bz2)   tar -xjf "$1"     ;;
			*.tar.gz)    tar -xzf "$1"     ;;
			*.rar)       unrar -e "$1"     ;;
			*.gz)        gunzip "$1"      ;;
			*.tar)       tar -xf "$1"      ;;
			*.tbz2)      tar -xjf "$1"     ;;
			*.tgz)       tar -xzf "$1"     ;;
			*.zip)       unzip "$1"       ;;
			*.Z)         uncompress "$1"  ;;
			*)     echo "'$1' cannot be extracted via extract()" ;;
		esac
	else
		echo "'$1' is not a valid file"
	fi
}

# appid
function appid () {
	local id
	id=$(osascript -e "id of app \"$1\"")
	echo "appid: $id"
	echo "$id" | pbcopy
}
