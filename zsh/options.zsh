# DOCS https://zsh.sourceforge.io/Doc/Release/Options.html
#───────────────────────────────────────────────────────────────────────────────

# GENERAL
setopt INTERACTIVE_COMMENTS # comments in interactive mode, useful for copypasting
setopt CORRECT
setopt GLOB_DOTS # glob includes dotfiles
setopt PIPE_FAIL # exit if pipeline failed

# colorized
function command_not_found_handler() {
	print "\e[1;33mCommand not found: \e[1;31m$1\e[0m"
	return 127
}

#───────────────────────────────────────────────────────────────────────────────
# HISTORY

export HISTSIZE=50000
export SAVEHIST=$HISTSIZE
export HISTFILE="$DATA_DIR/zsh_history" # to not save it in the (public) dotfiles repo

setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt NO_BANG_HIST # don't expand `!` (easier breaking changes in commit msgs)
setopt HIST_NO_STORE     # ignore history command itself
setopt HIST_IGNORE_SPACE # leading space is not added to the history

#───────────────────────────────────────────────────────────────────────────────
# LANGUAGE

# sets English everywhere, fixes encoding issues
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
