# COLORIZED HELP
alias -g H="--help | bat --language=help --style=plain --wrap=character"
ZSH_HIGHLIGHT_REGEXP+=(' H$' 'fg=magenta,bold')

#───────────────────────────────────────────────────────────────────────────────

# MAN PAGES
# - searches directly for $2 in the manpage of $1
# - works for builtin commands as well
# - opens in a new wezterm tab
# - fallsback to --help page if no manpage found
function man() {
	local command="$1"
	local search_term="$2"
	local pane_id

	if ! [[ "$TERM_PROGRAM" == "WezTerm" ]]; then echo "Not using WezTerm." && return 1; fi
	if ! command -v "$command" &> /dev/null; then echo "$command not installed." && return 1; fi
	if ! command -v bat &> /dev/null; then print "\e[1;33mbat not installed.\e[0m" && return 1; fi

	# INFO `test` is an exception, as it is a builtin command, but still has a
	# man page and no builtin help
	if [[ "$(type "$command")" =~ "builtin" ]] && [[ "$command" != "test" ]]; then
		if [[ ! -f "/usr/share/zsh/*/help/$command" ]]; then
			print "\e[1;33mNo builtin help found.\e[0m"
			return 1
		fi

		# using bat, since it adds some syntax highlighting to the builtin pages,
		# which man/less do not
		if [[ -n "$search_term" ]]; then
			pane_id=$(wezterm cli spawn -- bat --style=plain --language=man --pattern="$search_term" /usr/share/zsh/*/help/"$command")
		else
			pane_id=$(wezterm cli spawn -- bat --style=plain --language=man /usr/share/zsh/*/help/"$command")
		fi
	else
		if ! command man -w "$command" &> /dev/null; then
			# fallback to --help
			if ! $command --help | bat --language=help --style=plain --wrap=character; then
				print "\e[1;33mNeither man page nor --help page found.\e[0m"
				return 1
			fi
		fi
		if [[ -n "$search_term" ]]; then
			pane_id=$(wezterm cli spawn -- command man -P "less --pattern=$search_term" "$command")
		else
			pane_id=$(wezterm cli spawn -- command man "$command")
		fi
	fi
	# https://wezfurlong.org/wezterm/cli/cli/set-tab-title.html
	wezterm cli set-tab-title --pane-id="$pane_id" "docs: $command"
}

#───────────────────────────────────────────────────────────────────────────────

# CHEAT.SH
# aggregates stackoverflow, tl;dr and many other help pages
# DOCS https://cht.sh/:help
function cht() {
	# `curl cht.sh/:styles-demo`
	style=$(defaults read -g AppleInterfaceStyle &> /dev/null && echo "monokai" || echo "trac")

	query=${*// /-} # dash as separator for subcommands, e.g. git-rebase
	curl -s "https://cht.sh/$query?style=$style"
}

#───────────────────────────────────────────────────────────────────────────────
