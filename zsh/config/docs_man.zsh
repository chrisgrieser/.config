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

	local command="$1"
	local pane_id

	# INFO `test` is a builtin command, but has a better man page
	builtin_help=/usr/share/zsh/$ZSH_VERSION/help/$command
	lookup=$([[ -f "$builtin_help" && "$command" != "test"  ]] && echo "value1" || echo "value2")
	if [[ -f "$builtin_help" && "$command" != "test" ]]; then
		pane_id=$(wezterm cli spawn -- command man "$builtin_help")
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
