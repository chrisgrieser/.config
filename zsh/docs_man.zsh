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
function man () {
	command man "$1" -P "/usr/bin/less -is --pattern=$2"
}

#───────────────────────────────────────────────────────────────────────────────
# LESS config

export LESS_TERMCAP_mb=$'\E[1;31m' # begin bold
export LESS_TERMCAP_md=$'\E[1;33m' # begin blink = YELLOW
export LESS_TERMCAP_me=$'\E[0m'    # reset bold/blink
export LESS_TERMCAP_us=$'\E[1;35m' # begin underline = MAGENTA
export LESS_TERMCAP_ue=$'\E[0m'    # reset underline
export LESSHISTFILE=- # don't clutter the home directory with usless `.lesshst` file

# Pager-specific settings
# INFO less' --ignore-case is actually smart-case
export LESS='-R --incsearch --ignore-case --window=-3 --quit-if-one-screen --no-init --tilde'
