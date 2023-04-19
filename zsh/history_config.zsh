# Don't clutter home directory with useless `.node_repl_history`
# https://nodejs.org/api/repl.html#repl_environment_variable_options
export NODE_REPL_HISTORY=""

#───────────────────────────────────────────────────────────────────────────────
# https://www.soberkoder.com/better-zsh-history/
export HISTSIZE=1500
export SAVEHIST=$HISTSIZE

# so it isn't saved in the dotfile repo (privacy), but still synced
export HISTFILE="$DATA_DIR/zsh_history"

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

DATE_CHAR_COUNT=$(date "+$HIST_DATE_FORMAT" | wc -m | tr -d " ")
TO_CUT=$((DATE_CHAR_COUNT + 2))
function hs {
	SELECTED=$(
		history -t "$HIST_DATE_FORMAT" 1 | cut -c8- | fzf \
			--tac --no-sort \
			--no-info \
			--query "$*" \
			--height=60%
	)
	[[ -z "$SELECTED" ]] && return 0
	COMMAND=$(echo "$SELECTED" | cut -c"$TO_CUT"-)
	print -z "$COMMAND" # print to buffer
}
