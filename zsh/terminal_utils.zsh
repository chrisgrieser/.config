# better cd/z
function z () {
	if [[ -d "$1" ]] ; then
		z "$1"
	elif [[ -f  "$1" ]] ; then
		z "$(dirname "$1")"
	fi
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

# Move to trash via Finder (allows retrievability)
# no arg = all files in folder will be deleted
function del () {
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

function view () {
	qlmanage -p "$*" &> /dev/null
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
