#!/usr/bin/env zsh

# DOCS https://zsh.sourceforge.io/Doc/Release/Options.html
setopt HIST_IGNORE_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY
setopt HIST_NO_STORE     # ignore history command itself for the history
setopt HIST_IGNORE_SPACE # leading space is not added to the history

# DOCS https://zsh.sourceforge.io/Doc/Release/Parameters.html#Parameters-Used-By-The-Shell
export HISTSIZE=3000
export SAVEHIST=$HISTSIZE
export HISTFILE="$DATA_DIR/zsh_history.zsh" # don't save in ZDOTDIR as it's in (public) dotfile repo

#───────────────────────────────────────────────────────────────────────────────

# copies result of last command
function lr() {
	to_copy=$(eval "$(history -n -1)")
	print "\e[1;32mCopied:\e[0m $to_copy"
	echo -n "$to_copy" | pbcopy
}

# copies last command(s)
function lc() {
	local to_copy
	if [[ $# -gt 0 ]] ; then
		to_copy=""
		for arg in "$@"; do
			to_copy="$to_copy\n$arg"
		done
	else
		to_copy=$(history -n -1)
	fi
	print "\e[1;32mCopied:\e[0m "
	echo "$to_copy"
	echo -n "$to_copy" | pbcopy
}

# completions for it
_last_commands () {
	# shellcheck disable=2296 # valid in zsh
	typeset -a recent_cmds=("${(f)"$(history -rn | sed "s/'/\\\'/g")"}") # lines to array
	local expl
	_description -V last-commands expl 'Last Commands'
	compadd "${expl[@]}" -Q -P"$'" -S"'" -- "${recent_cmds[@]}"
}
compdef _last_commands lc
