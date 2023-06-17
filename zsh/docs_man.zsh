# search cht.sh for information
# aggregates stackoverflow, tl;dr and many other help pages
# https://cht.sh/:help
function h() {
	local style query

	# curl cht.sh/:styles-demo
	local lightstyle="trac"
	local darkstyle="monokai"
	defaults read -g AppleInterfaceStyle &>/dev/null && style="$darkstyle" || style="$lightstyle"

	query=$(echo "$*" | sed 's/ /\//' | tr " " "+") # first space → /, all other spaces "+" for url
	if [[ "$TERM_PROGRAM" == "WezTerm" ]]; then
		curl -s "https://cht.sh/$query?style=$style" >"/tmp/$query"
		wezterm cli spawn -- less "/tmp/$query" | xargs -I {} wezterm cli set-tab-title --pane-id={} "cheat – $query "
	else
		curl -s "https://cht.sh/$query?style=$style" | less
	fi
}

# GET A BETTER MAN
function man() {
	local command="$1"
	local search_term="$2"
	if [[ "$TERM_PROGRAM" == "WezTerm" ]]; then
		# https://wezfurlong.org/wezterm/cli/cli/set-tab-title.html
		if [[ -n "$search_term" ]]; then
			wezterm cli spawn -- man -P "/usr/bin/less -is --pattern=$search_term" "$command" | xargs -I {} wezterm cli set-tab-title --pane-id={} "man: $command "
		else
			wezterm cli spawn -- man "$command" | xargs -I {} wezterm cli set-tab-title --pane-id={} "man – $command "
		fi
	else
		if [[ -n "$search_term" ]]; then
			command man -P "/usr/bin/less -is --pattern=$search_term" "$command"
		else
			command man "$command"
		fi
	fi
}

#───────────────────────────────────────────────────────────────────────────────
# ChatGPT
# https://platform.openai.com/docs/api-reference/making-requests
# uses OPENAI_API_KEY saved in .zshenv
function ai() {
	if ! command -v yq &>/dev/null; then echo "yq not installed." && return 1; fi
	if ! command -v bat &>/dev/null; then echo "bat not installed." && return 1; fi

	local query="$*"
	# WARN do not use "$prompt" as a variable in zsh, since it's a reserved keyword
	local the_prompt="The following request is concerned with shell scripting. If your response includes codeblocks, do add 'bash' as language label to it. Here is the request: $query"
	local answer
	answer=$(curl "https://api.openai.com/v1/chat/completions" \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $OPENAI_API_KEY" \
		-d "{
			\"model\": \"gpt-3.5-turbo\",
			\"messages\": [{\"role\": \"user\", \"content\": \"$the_prompt\"}],
			\"temperature\": 0
		}" |
		yq -r '.choices[].message.content')
	echo "$answer" | bat --language=markdown --style=grid --wrap=auto
}

#───────────────────────────────────────────────────────────────────────────────
# LESS config

export LESS_TERMCAP_mb=$'\E[1;31m' # begin bold
export LESS_TERMCAP_md=$'\E[1;33m' # begin blink = YELLOW
export LESS_TERMCAP_me=$'\E[0m'    # reset bold/blink
export LESS_TERMCAP_us=$'\E[1;35m' # begin underline = MAGENTA
export LESS_TERMCAP_ue=$'\E[0m'    # reset underline
export LESSHISTFILE=-              # don't clutter home directory with useless `.lesshst` file

# Pager-specific settings
# INFO less' --ignore-case is actually smart-case
export LESS='-R --incsearch --ignore-case --window=-3 --no-init --tilde'
