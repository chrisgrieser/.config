# Don't clutter home directory with useless `.node_repl_history`
# https://nodejs.org/api/repl.html#repl_environment_variable_options
export NODE_REPL_HISTORY=""

#───────────────────────────────────────────────────────────────────────────────
# https://www.soberkoder.com/better-zsh-history/
export HISTSIZE=1500
export SAVEHIST=$HISTSIZE

# so it isn't saved in the dotfile repo (privacy), but still synced
export HISTFILE="$DATA_DIR/zsh_history"
export HIST_DATE_FORMAT='%a %d.%m %H:%M   ' # custom, defined by me

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
eval "$(atuin init zsh)"
# to use custom atuin keybindings: https://atuin.sh/docs/config/key-binding
