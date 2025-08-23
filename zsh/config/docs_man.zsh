# COLORIZED HELP
alias -g H="--help | bat --language=help --style=plain"
ZSH_HIGHLIGHT_REGEXP+=(' H$' 'fg=magenta,bold')

#───────────────────────────────────────────────────────────────────────────────

# MAN PAGES 
export MANPAGER="nvim +Man!"

# open in new wezterm tab
# - works for builtin commands as well
# - opens in a new wezterm tab
# - fallsback to --help page if no manpage found
function man() {
	if ! [[ "$TERM_PROGRAM" == "WezTerm" ]]; then echo "Not using WezTerm." && return 1; fi
	if ! command -v "$command" &> /dev/null; then echo "$command not installed." && return 1; fi

	local command="$1"
	local pane_id
	pane_id=$(wezterm cli spawn -- command man "$command")

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
