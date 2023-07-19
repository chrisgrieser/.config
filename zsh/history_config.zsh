# Don't clutter home directory with useless `.node_repl_history`
# https://nodejs.org/api/repl.html#repl_environment_variable_options
export NODE_REPL_HISTORY=""

#───────────────────────────────────────────────────────────────────────────────
# https://www.soberkoder.com/better-zsh-history/
export HISTSIZE=1500
export SAVEHIST=$HISTSIZE
export HISTFILE="$DATA_DIR/zsh_history"

# https://zsh.sourceforge.io/Doc/Release/Parameters.html#Parameters-Used-By-The-Shell
export HISTORY_IGNORE="(..|inspect|q)"
# HISTORY_IGNORE only prevents stuff being writtein to the history file, so this
# event hook is needed to prevent it from being written during an interactive
# session already
zshaddhistory() {
	emulate -L zsh
	# shellcheck disable=2053,2296
	[[ $1 != ${~HISTORY_IGNORE} ]]
}

setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_VERIFY
setopt EXTENDED_HISTORY

#───────────────────────────────────────────────────────────────────────────────

export HIST_DATE_FORMAT='%a %d.%m %H:%M   ' # custom, defined by me

# SEARCH HISTORY FOR A COMMAND
# enter ➞ write to buffer (without sending)
# alt+enter ➞ copy to clipboard
function hs {
	local date_char_count selected to_cut command
	date_char_count=$(date "+$HIST_DATE_FORMAT" | wc -m | tr -d " ")
	to_cut=$((date_char_count + 2))
	selected=$(
		history -t "$HIST_DATE_FORMAT" 1 | cut -c8- | fzf \
			--tac --no-sort \
			--no-info \
			--query "$*" \
			--height=60%
	)
	[[ -z "$selected" ]] && return 0
	command=$(echo "$selected" | cut -c"$to_cut"-)
	print -z "$command" # print to buffer
}
