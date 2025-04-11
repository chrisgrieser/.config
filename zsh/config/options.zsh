# DOCS 
# https://zsh.sourceforge.io/Doc/Release/Options.html
# https://zsh.sourceforge.io/Doc/Release/Parameters.html#Parameters-Used-By-The-Shell
#───────────────────────────────────────────────────────────────────────────────

# GENERAL
setopt INTERACTIVE_COMMENTS # comments in interactive mode, useful for copypasting
setopt GLOB_DOTS            # glob includes dotfiles
setopt PIPE_FAIL            # tracability: exit if pipeline failed
setopt NO_BANG_HIST         # don't expand `!`

# colorized 127 error code
function command_not_found_handler() {
	print "\e[1;33mCommand not found: \e[1;31m$1\e[0m"
	return 127
}

# auto-escape special characters when pasting URLs
autoload -U url-quote-magic bracketed-paste-magic
zle -N self-insert url-quote-magic
zle -N bracketed-paste bracketed-paste-magic

#───────────────────────────────────────────────────────────────────────────────

# HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY # write immediately to history file
setopt HIST_NO_STORE      # ignore history command itself for the history
setopt HIST_IGNORE_SPACE  # cmds with leading space are not added to the history

export HISTSIZE=20000
export SAVEHIST=$HISTSIZE
# don't save in `$ZDOTDIR` as it's in my public dotfile repo
export HISTFILE="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/zsh_history.zsh"

#───────────────────────────────────────────────────────────────────────────────
# LANGUAGE

# sets English everywhere, fixes encoding issues
export LANG="en_US.UTF-8"
export LC_ALL="$LANG"
export LC_CTYPE="$LANG"
