# search cht.sh for information
# aggregates stackoverflow, tl;dr and many other help pages
function cc () {
	QUERY=$(echo "$*" | sed 's/ /\//' | tr " " "+") # first space → /, all other spaces "+" for url
	CHEAT_INFO=$(curl -s "https://cht.sh/$QUERY") # https://cht.sh/:help
	CHEAT_CODE_ONLY=$(curl -s "https://cht.sh/$QUERY?T")
	echo "$CHEAT_INFO" | less
	echo "$CHEAT_CODE_ONLY" | pbcopy
}

# Better Man
# first arg: command, second arg: search term
function man () {
 	CONFIG=~"/.config/alacritty/man-page.yml"

	if ! which alacritty &> /dev/null; then
		echo "Not using Alacritty." ; return 1
	elif ! which "$1" &> /dev/null; then
		echo "Command '$1' not installed." ; return 1
 	fi

 	local isBuiltIn=false
 	[[ "$(which "$1")" =~ "built-in" ]] && isBuiltIn=true
 	if [[ "$1" == "test" ]] || [[ "$1" == "kill" ]] ; then # builtIn command which *do* have a man page
 		isBuiltIn=false
 	fi

	# run in subshell to surpress output
 	if [[ $isBuiltIn == true ]] && [[ -z "$2" ]] ; then
 		(alacritty --config-file="$CONFIG" --title="built-in help: $1" --command less /usr/share/zsh/*/help/"$1" &)
 	elif [[ $isBuiltIn == true ]] && [[ -n "$2" ]] ; then
 		(alacritty --config-file="$CONFIG" --title="built-in help: $1" --command less --pattern="$2" /usr/share/zsh/*/help/"$1" &)
	elif [[ $isBuiltIn == false ]] && [[ -z "$2" ]] ; then
		(alacritty --config-file="$CONFIG" --title="man: $1" --command man "$1" &)
	else
		(alacritty --config-file="$CONFIG" --title="man: $1" --command man "$1" -P "/usr/bin/less -is --pattern=$2" &)
	fi
}

# simpler version for people reading my dotfiles to snatch
# function man () {
# 	command man "$1" -P "/usr/bin/less -is --pattern=$2"
# }

# colorize less https://wiki.archlinux.org/index.php/Color_output_in_console#less .
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\E[1;33m'     # begin blink = YELLOW
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_us=$'\E[1;35m'     # begin underline = MAGENTA
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

# Pager-specific settings
# (INFO: less ignore-case is actually smart case)
export LESS='-R --ignore-case --window=-3 --quit-if-one-screen --no-init --tilde'

