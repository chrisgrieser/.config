#!/usr/bin/env zsh

# DOCS https://zsh.sourceforge.io/Doc/Release/Options.html
setopt HIST_IGNORE_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY # write immediately to history file
setopt HIST_NO_STORE      # ignore history command itself for the history
setopt HIST_IGNORE_SPACE  # cmds with leading space are not added to the history

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
	local to_copy cmd
	if [[ $# -gt 0 ]]; then
		to_copy=""
		for arg in "$@"; do
			cmd=$(history -n -"$arg" -"$arg")
			to_copy="$to_copy$cmd\n"
		done
	else
		to_copy=$(history -n -1)
	fi
	print "\e[1;32mCopied:\e[0m"
	echo -n "$to_copy"
	echo -n "$to_copy" | pbcopy
}

# completions for it
_lc () {
	# turn lines into array
	local -a _last_cmds=()
	while IFS='' read -r value; do
		_last_cmds+=("$value")
	done < <(history -rn)

	local _values=({1..16})
	local expl
	_description -V last-commands expl 'Last Commands'
	compadd "${expl[@]}" -Q -l -d _last_cmds -a _values
}
compdef _lc lc
