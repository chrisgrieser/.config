# Don't clutter home directory with useless `.node_repl_history`
# https://nodejs.org/api/repl.html#repl_environment_variable_options
export NODE_REPL_HISTORY=""

#───────────────────────────────────────────────────────────────────────────────
# https://www.soberkoder.com/better-zsh-history/
export HISTSIZE=1500
export SAVEHIST=$HISTSIZE
export HISTORY_IGNORE="(..|inspect)"
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
# LOAD ATUIN
# disable arrow key https://atuin.sh/docs/config/key-binding
eval "$(atuin init zsh --disable-up-arrow)"
