# CHEAT.SH
# aggregates stackoverflow, tl;dr and many other help pages
# https://cht.sh/:help
function h() {
	local style query pane_id

	# curl cht.sh/:styles-demo
	local lightstyle="trac"
	local darkstyle="monokai"
	defaults read -g AppleInterfaceStyle &>/dev/null && style="$darkstyle" || style="$lightstyle"

	query=$(echo "$*" | sed 's/ /\//' | tr " " "+") # first space → /, all other spaces "+" for url
	if [[ "$TERM_PROGRAM" == "WezTerm" ]]; then
		curl -s "https://cht.sh/$query?style=$style" >"/tmp/$query"
		pane_id=$(wezterm cli spawn -- less "/tmp/$query")
		wezterm cli set-tab-title --pane-id="$pane_id" "cheat: $query"
	else
		curl -s "https://cht.sh/$query?style=$style" | less
	fi
}

#───────────────────────────────────────────────────────────────────────────────

# COLORIZED HELP
# `--` ensures dash can be used in the alias name
# `--help` and `-h` offer help pages of different length for some commands, e.g. fd
alias -g -- -h='-h | bat --language=help --style=plain --wrap=character'
alias -g -- --help='--help | bat --language=help --style=plain --wrap=character'

#───────────────────────────────────────────────────────────────────────────────

# BETTER MAN
# - searches directly for $2 in the manpage of $1
# - works for builtin commands as well
# - opens in a new wezterm tab
function man() {
	local command="$1"
	local search_term="$2"

	if ! command -v "$command" &>/dev/null; then echo "$command not installed." && return 1; fi
	if ! [[ "$TERM_PROGRAM" == "WezTerm" ]]; then echo "Not using WezTerm." && return 1; fi
	if ! command -v bat &>/dev/null; then printf "\033[1;33mbat not installed.\033[0m" && return 1; fi

	local pane_id
	if [[ "$(type "$command")" =~ "builtin" ]]; then
		# using bat, since it adds some syntax highlighting to the builtin pages,
		# which man/less does not
		if [[ -n "$search_term" ]]; then
			pane_id=$(wezterm cli spawn -- bat --style=plain --language=man --pattern="$search_term" /usr/share/zsh/*/help/"$command")
		else
			pane_id=$(wezterm cli spawn -- bat --style=plain --language=man /usr/share/zsh/*/help/"$command")
		fi
	else
		if [[ -n "$search_term" ]]; then
			pane_id=$(wezterm cli spawn -- man -P "less --pattern=$search_term" "$command")
		else
			pane_id=$(wezterm cli spawn -- man "$command")
		fi
	fi
	# https://wezfurlong.org/wezterm/cli/cli/set-tab-title.html
	wezterm cli set-tab-title --pane-id="$pane_id" "man: $command"
}

#───────────────────────────────────────────────────────────────────────────────
# CHATGPT

function ai() {
	if ! command -v yq &>/dev/null; then echo "yq not installed." && return 1; fi
	if ! command -v bat &>/dev/null; then echo "bat not installed." && return 1; fi
	if [[ -z "$OPENAI_API_KEY" ]]; then echo "$OPENAI_API_KEY not found." && return 1; fi

	local query="$*"
	# WARN do not use "$prompt" as a variable in zsh, since it's a reserved keyword
	local the_prompt="The following request is concerned with shell scripting. If your response includes codeblocks, do add 'bash' as language label to it. Here is the request: $query"
	# https://platform.openai.com/docs/api-reference/making-requests
	curl "https://api.openai.com/v1/chat/completions" \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $OPENAI_API_KEY" \
		-d "{
			\"model\": \"gpt-3.5-turbo\",
			\"messages\": [{\"role\": \"user\", \"content\": \"$the_prompt\"}],
			\"temperature\": 0
		}" |
		yq -r '.choices[].message.content' |
		bat --language=markdown --style=plain --wrap=auto
}

#───────────────────────────────────────────────────────────────────────────────
# LESS

export LESS_TERMCAP_mb=$'\E[1;31m' # begin bold
export LESS_TERMCAP_md=$'\E[1;33m' # begin blink
export LESS_TERMCAP_me=$'\E[0m'    # reset bold/blink
export LESS_TERMCAP_us=$'\E[1;36m' # begin underline
export LESS_TERMCAP_ue=$'\E[0m'    # reset underline

export LESS='-R --incsearch --ignore-case --window=-3 --no-init --tilde' # --ignore-case is actually smart case
export LESSHISTFILE=- # don't clutter home directory with useless `.lesshst` file

# Keybindings
# INFO 
# - macOS currently ships less v.581, which lacks the ability to read lesskey
#   source files. Therefore for this to work, the version of less provided by
#   homebrew is needed (v.633)
# - keybinding for search includes a setting that makes `n` and `N` wrap
export LESSKEYIN="$DOTFILE_FOLDER/zsh/.lesskey"
