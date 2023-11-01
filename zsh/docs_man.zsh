# CHEAT.SH
# aggregates stackoverflow, tl;dr and many other help pages
# https://cht.sh/:help
function h() {
	local style pane_id
	local query="$*"

	# curl cht.sh/:styles-demo
	local lightstyle="trac"
	local darkstyle="monokai"
	defaults read -g AppleInterfaceStyle &>/dev/null && style="$darkstyle" || style="$lightstyle"

	query=${query// /-} # dash as separator for subcommands, e.g. git-rebase
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
batpipe="2>&1 | bat --language=help --style=plain --wrap=character"
# shellcheck disable=2139
alias -g -- -h="-h $batpipe"
# shellcheck disable=2139
alias -g -- --help="--help $batpipe"
# shellcheck disable=2139
alias -g H="--help $batpipe"
ZSH_HIGHLIGHT_REGEXP+=(' H$' 'fg=magenta,bold')

#───────────────────────────────────────────────────────────────────────────────

# SUPER MAN
# - searches directly for $2 in the manpage of $1
# - works for builtin commands as well
# - opens in a new wezterm tab
# - fallsback to --help page if no manpage found
function man() {
	local command="$1"
	local search_term="$2"
	local pane_id

	if ! [[ "$TERM_PROGRAM" == "WezTerm" ]]; then echo "Not using WezTerm." && return 1; fi
	if ! command -v "$command" &>/dev/null; then echo "$command not installed." && return 1; fi
	if ! command -v bat &>/dev/null; then print "\033[1;33mbat not installed.\033[0m" && return 1; fi

	# INFO `test` is an exception, as it is a builtin command, but still has a
	# man page and no builtin help
	if [[ "$(type "$command")" =~ "builtin" ]] && [[ "$command" != "test" ]]; then
		if [[ ! -f "/usr/share/zsh/*/help/$command" ]]; then
			print "\033[1;33mNo builtin help found.\033[0m"
			return 1
		fi

		# using bat, since it adds some syntax highlighting to the builtin pages,
		# which man/less does not
		# INFO `` makes less wrap the search (since less version 582)
		if [[ -n "$search_term" ]]; then
			pane_id=$(wezterm cli spawn -- bat --style=plain --language=man --pattern="$search_term" /usr/share/zsh/*/help/"$command")
		else
			pane_id=$(wezterm cli spawn -- bat --style=plain --language=man /usr/share/zsh/*/help/"$command")
		fi
	else
		if ! command man -w "$command" &>/dev/null; then
			# fallback to --help
			if ! $command --help | bat --language=help --style=plain --wrap=character; then
				print "\033[1;33mNeither man page nor --help page found.\033[0m"
				return 1
			fi
		fi
		if [[ -n "$search_term" ]]; then
			pane_id=$(wezterm cli spawn -- command man -P "less --pattern=$search_term" "$command")
		else
			pane_id=$(wezterm cli spawn -- command man "$command")
		fi
	fi
	# https://wezfurlong.org/wezterm/cli/cli/set-tab-title.html
	wezterm cli set-tab-title --pane-id="$pane_id" "docs: $command"
}

#───────────────────────────────────────────────────────────────────────────────
# LESS

# have `less` colorize man pages
# export LESS_TERMCAP_mb=$'\E[1;31m' # begin bold
# export LESS_TERMCAP_md=$'\E[1;33m' # begin blink
# export LESS_TERMCAP_me=$'\E[0m'    # reset bold/blink
# export LESS_TERMCAP_us=$'\E[1;36m' # begin underline
# export LESS_TERMCAP_ue=$'\E[0m'    # reset underline

# have `bat` colorize man pages
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
man 2 select

#------------

# --ignore-case is actually smart case
export LESS='--RAW-CONTROL-CHARS --incsearch --ignore-case --window=-3 --no-init --tilde --long-prompt'
export LESSHISTFILE=- # don't clutter home directory with useless `.lesshst` file

# INFO Keybindings
# - macOS currently ships less v.581, which lacks the ability to read lesskey
#   source files. Therefore for this to work, the version of less provided by
#   homebrew is needed (v.633)
# - keybinding for search includes a setting that makes `n` and `N` wrap
export PAGER="less" # needs to be set explicitly, so the homebrew version is used
export LESSKEYIN="$ZDOTDIR/.lesskey"

less_version=$(less --version | grep -E --only-matching --max-count=1 "[0-9.]{2,}")
[[ $less_version -lt 582 ]] &&
	echo "Installed version of less is lower than v.582, does not support all features."
