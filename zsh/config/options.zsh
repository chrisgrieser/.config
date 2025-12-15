# DOCS 
# https://zsh.sourceforge.io/Doc/Release/Options.html
# https://zsh.sourceforge.io/Doc/Release/Parameters.html#Parameters-Used-By-The-Shell
#───────────────────────────────────────────────────────────────────────────────

# GENERAL
setopt INTERACTIVE_COMMENTS # comments in interactive mode, useful for copypasting
setopt PIPE_FAIL            # tracebility: exit if pipeline failed
setopt NO_BANG_HIST         # don't expand `!`, since used for commit messages

# HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY # write immediately to history file
setopt HIST_NO_STORE      # ignore history command itself for the history
setopt HIST_IGNORE_SPACE  # cmds with leading space are not added to the history

# 1. not in `$ZDOTDIR` as it is in public dotfiles repo
# 2. not in iCloud due to frequent merge conflicts
export HISTFILE="$HOME/.local/share/zsh/zsh_history.zsh"

export HISTSIZE=20000
export SAVEHIST=$HISTSIZE

# LANGUAGE
# set English everywhere, fixes encoding issues
export LANG="en_US.UTF-8"
export LC_ALL="$LANG"
export LC_CTYPE="$LANG"
