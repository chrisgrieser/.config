function cc () {
	QUERY=$(echo "$*" | sed 's/ /\//' | tr " " "+") # first space → /, all other spaces "+" for url
	CHEAT_INFO=$(curl -s "https://cht.sh/$QUERY") # https://cht.sh/:help
	CHEAT_CODE_ONLY=$(curl -s "https://cht.sh/$QUERY?TQ")
	echo "$CHEAT_INFO" | "$PAGER"
	echo "$CHEAT_CODE_ONLY" | pbcopy
}

# first arg: command
# second arg: search term
function man () {
	if ! which alacritty &> /dev/null; then
		echo "Not using Alacritty."
		return 1
	fi
	if ! which "$1" &> /dev/null; then
		echo "Command '$1' not installed."
		return 1
	fi
	if ! which "$PAGER" &> /dev/null; then
 		echo "Pager '$PAGER' not installed."
 		return 1
 	fi

	if [[ -z "$2" ]] ; then
		# run in subshell to surpress output
		(alacritty \
			--option=window.decorations=full \
			--title="man $1" \
			--command man "$1" &)
	else
		(alacritty \
			--option=window.decorations=full \
			--title="man $1" \
			--command man "$1" -P "/usr/bin/less -is --pattern=$2" &)
	fi
}

# man pages for zsh-builtins https://stackoverflow.com/a/35456287
unalias run-help 2>/dev/null
autoload run-help
alias help='run-help'
zsh_ver=$(zsh --version | cut -d" " -f2)
export HELPDIR="/usr/share/zsh/$zsh_ver/help"

export PAGER=less

# colorize less https://wiki.archlinux.org/index.php/Color_output_in_console#less .
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\E[1;33m'     # begin blink
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_us=$'\E[1;34m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

# Pager-specific settings
export LESS='-R --incsearch --ignore-case --HILITE-UNREAD --window=-3 --quit-at-eof --quit-if-one-screen --no-init --tilde'

