# DOCS https://zsh.sourceforge.io/Doc/Release/Options.html
# DOCS https://zsh.sourceforge.io/Doc/Release/Parameters.html#Parameters-Used-By-The-Shell
#───────────────────────────────────────────────────────────────────────────────

# GENERAL
setopt INTERACTIVE_COMMENTS # comments in interactive mode, useful for copypasting
setopt GLOB_DOTS            # glob includes dotfiles
setopt PIPE_FAIL            # tracability: exit if pipeline failed

# colorized
function command_not_found_handler() {
	print "\e[1;33mCommand not found: \e[1;31m$1\e[0m"
	return 127
}

#───────────────────────────────────────────────────────────────────────────────

# HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY # write immediately to history file
setopt HIST_NO_STORE      # ignore history command itself for the history
setopt HIST_IGNORE_SPACE  # cmds with leading space are not added to the history

export HISTSIZE=5000
export SAVEHIST=$HISTSIZE
export HISTFILE="$DATA_DIR/zsh_history.zsh" # don't save in ZDOTDIR as it's in (public) dotfile repo

#───────────────────────────────────────────────────────────────────────────────
# LANGUAGE

# sets English everywhere, fixes encoding issues
export LANG="en_US.UTF-8"
export LC_ALL="$LANG"
export LC_CTYPE="$LANG"
