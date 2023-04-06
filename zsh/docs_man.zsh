# search cht.sh for information
# aggregates stackoverflow, tl;dr and many other help pages
function h() {
	QUERY=$(echo "$*" | sed 's/ /\//' | tr " " "+") # first space → /, all other spaces "+" for url
	CHEAT_INFO=$(curl -s "https://cht.sh/$QUERY")   # https://cht.sh/:help
	CHEAT_CODE_ONLY=$(curl -s "https://cht.sh/$QUERY?QT")
	echo "$CHEAT_INFO" | less
	echo "$CHEAT_CODE_ONLY" | pbcopy
}

# GET A BETTER MAN
# if in wezterm, opens man in a new tab
# first arg: command, second arg: search term
function man() {
	if [[ "$TERM_PROGRAM" != "WezTerm" && -n "$2" ]]; then
		command man -P "/usr/bin/less -is --pattern=$2" "$1"
	elif [[ "$TERM_PROGRAM" != "WezTerm" ]]; then
		command man "$1"
	elif [[ -n "$2" ]]; then
		wezterm cli spawn -- man -P "/usr/bin/less -is --pattern=$2" "$1" &>/dev/null
	else
		wezterm cli spawn -- man "$1" &>/dev/null
	fi
}

#───────────────────────────────────────────────────────────────────────────────
# ChatGPT
# https://platform.openai.com/docs/api-reference/making-requests
# uses OPENAI_API_KEY saved in .zshenv
function ai() {
	if ! command -v yq &>/dev/null; then echo "yq not installed." && return 1; fi

	query="$*" # WARN do not use "prompt" as a variable in zsh, it's a reserved keyword
	curl "https://api.openai.com/v1/chat/completions" \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $OPENAI_API_KEY" \
		-d "{
		\"model\": \"gpt-3.5-turbo\",
		\"messages\": [{\"role\": \"user\", \"content\": \"$query\"}],
		\"temperature\": 0
	}" |
	yq -r '.choices[].message.content'
}

#───────────────────────────────────────────────────────────────────────────────
# LESS config

export LESS_TERMCAP_mb=$'\E[1;31m' # begin bold
export LESS_TERMCAP_md=$'\E[1;33m' # begin blink = YELLOW
export LESS_TERMCAP_me=$'\E[0m'    # reset bold/blink
export LESS_TERMCAP_us=$'\E[1;35m' # begin underline = MAGENTA
export LESS_TERMCAP_ue=$'\E[0m'    # reset underline
export LESSHISTFILE=-              # don't clutter the home directory with usless `.lesshst` file

# Pager-specific settings
# INFO less' --ignore-case is actually smart-case
export LESS='-R --incsearch --ignore-case --window=-3 --quit-if-one-screen --no-init --tilde'
