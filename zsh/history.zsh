#!/usr/bin/env zsh

setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt NO_BANG_HIST # don't expand `!` (easier breaking changes in commit msgs)
setopt HIST_NO_STORE     # ignore history command itself
setopt HIST_IGNORE_SPACE # leading space is not added to the history

export HISTSIZE=50000
export SAVEHIST=$HISTSIZE
export HISTFILE="$DATA_DIR/zsh_history" # to not save it in the (public) dotfiles repo

# copies last command(s)
function lc() {
	# shellcheck disable=2001
	to_copy=$(echo "$*" | sed -e "s/'/\\'/g")
	print "\e[1;32mCopied:\e[0m $to_copy"
	echo -n "$to_copy" | pbcopy
}

# copies result of last command(s)
function lr() {
	to_copy=$(eval "$1")
	print "\e[1;32mCopied:\e[0m $to_copy"
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
compdef _last_commands lr
