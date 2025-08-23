# COLORIZED `--help`
alias -g H="--help | bat --language=help --style=plain"
ZSH_HIGHLIGHT_REGEXP+=(' H$' 'fg=magenta,bold')

#───────────────────────────────────────────────────────────────────────────────

# MAN PAGES
export MANPAGER="nvim +Man!"

# 1. open in new wezterm tab
# 2. search builtin commands, which do not have man pages
function man() {
	if ! [[ "$TERM_PROGRAM" == "WezTerm" ]]; then echo "Not using WezTerm." && return 1; fi
	if ! command -v "$command" &> /dev/null; then echo "$command not installed." && return 1; fi

	local command="$1"
	local pane_id
	pane_id=$(wezterm cli spawn -- command man "$command")

	# INFO `test` is an exception, as it is a builtin command, but still has a
	# man page and no builtin help
	if [[ "$(type "$command")" =~ "builtin" ]] && [[ "$command" != "test" ]]; then
		if [[ ! -f "/usr/share/zsh/*/help/$command" ]]; then
			print "\e[1;33mNo builtin help found.\e[0m" 
			return 1
		fi
		pane_id=$(wezterm cli spawn -- command man /usr/share/zsh/*/help/"$command")
	else
		pane_id=$(wezterm cli spawn -- command man "$command")
	fi

	# https://wezfurlong.org/wezterm/cli/cli/set-tab-title.html
	wezterm cli set-tab-title --pane-id="$pane_id" " $command"
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
