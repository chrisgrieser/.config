# search cht.sh for information
# aggregates stackoverflow, tl;dr and many other help pages
function sh() {
	QUERY=$(echo "$*" | sed 's/ /\//' | tr " " "+") # first space → /, all other spaces "+" for url
	CHEAT_INFO=$(curl -s "https://cht.sh/$QUERY")   # https://cht.sh/:help
	CHEAT_CODE_ONLY=$(curl -s "https://cht.sh/$QUERY?QT")
	echo "$CHEAT_INFO" | less
	echo "$CHEAT_CODE_ONLY" | pbcopy
}

# GET A BETTER MAN
# first arg: command, second arg: search term
function man() {
	if ! command -v alacritty &>/dev/null; then echo "alacritty not installed." && return 1; fi
	if ! command -v "$1" &>/dev/null; then echo "$1 not installed." && return 1; fi
	
	local alacrittyConfig="$HOME/.config/alacritty/man-page.yml"
	local title="man: $1"
	local isBuiltIn=false
	[[ "$(which "$1")" =~ built-in ]] && isBuiltIn=true
	if [[ "$1" == "test" ]] || [[ "$1" == "kill" ]]; then # builtIn commands which *do* have a man page
		isBuiltIn=false
	fi

	if [[ $isBuiltIn == true ]] && [[ -z "$2" ]]; then
		(alacritty --config-file="$alacrittyConfig" --title="$title" --command less /usr/share/zsh/*/help/"$1" &) &>/dev/null
	elif [[ $isBuiltIn == true ]] && [[ -n "$2" ]]; then
		(alacritty --config-file="$alacrittyConfig" --title="$title" --command less --pattern="$2" /usr/share/zsh/*/help/"$1" &) &>/dev/null
	elif [[ $isBuiltIn == false ]] && [[ -z "$2" ]]; then
		(alacritty --config-file="$alacrittyConfig" --title="$title" --command man "$1" &) &>/dev/null
	else
		(alacritty --config-file="$alacrittyConfig" --title="$title" --command man -P "/usr/bin/less -is --pattern=$2" "$1" &) &>/dev/null
	fi
}

# # simpler version without alacritty for people reading my dotfiles to snatch
# function man () {
# 	command man "$1" -P "/usr/bin/less -is --pattern=$2"
# }

# colorize less https://wiki.archlinux.org/index.php/Color_output_in_console#less .
export LESS_TERMCAP_mb=$'\E[1;31m' # begin bold
export LESS_TERMCAP_md=$'\E[1;33m' # begin blink = YELLOW
export LESS_TERMCAP_me=$'\E[0m'    # reset bold/blink
export LESS_TERMCAP_us=$'\E[1;35m' # begin underline = MAGENTA
export LESS_TERMCAP_ue=$'\E[0m'    # reset underline

# Pager-specific settings
# INFO less' --ignore-case is actually smart-case
export LESS='-R --incsearch --ignore-case --window=-3 --quit-if-one-screen --no-init --tilde'
