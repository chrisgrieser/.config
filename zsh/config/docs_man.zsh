# --HELP PAGE
# colorized
alias -g H="--help | bat --language=help --style=plain --wrap=character"
ZSH_HIGHLIGHT_REGEXP+=(' H$' 'fg=magenta,bold')

#───────────────────────────────────────────────────────────────────────────────

# MAN PAGES
export MANPAGER="nvim +Man!"

# 1. open in new wezterm tab
# 2. search builtin commands, which do not have man pages
function man() {
	if ! [[ "$TERM_PROGRAM" == "WezTerm" ]]; then echo "Not using WezTerm." && return 1; fi

	local command="$1"
	local pane_id builtin_help lookup

	# INFO `test` is a builtin command, but has a better man page
	builtin_help=/usr/share/zsh/$ZSH_VERSION/help/$command
	lookup=$([[ -f "$builtin_help" && "$command" != "test" ]] && echo "$builtin_help" || echo "$command")
	pane_id=$(wezterm cli spawn -- command man "$lookup")

	wezterm cli set-tab-title --pane-id="$pane_id" " $command" # https://wezfurlong.org/wezterm/cli/cli/set-tab-title.html
}

#───────────────────────────────────────────────────────────────────────────────
