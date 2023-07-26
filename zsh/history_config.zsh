# Don't clutter home directory with useless `.node_repl_history`
# https://nodejs.org/api/repl.html#repl_environment_variable_options
export NODE_REPL_HISTORY=""

#───────────────────────────────────────────────────────────────────────────────
# https://www.soberkoder.com/better-zsh-history/
export HISTSIZE=4000
export SAVEHIST=$HISTSIZE
export HISTFILE="$DATA_DIR/zsh_history"

setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_VERIFY
setopt EXTENDED_HISTORY

setopt HIST_NO_STORE # ignore history command itself
setopt HIST_IGNORE_SPACE # leading space is not added to the history

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
