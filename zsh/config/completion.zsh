# DOCS
# zsh docs                  https://zsh.sourceforge.io/Guide/zshguide06.html
# zstyle                    https://zsh.sourceforge.io/Doc/Release/Completion-System.html#Standard-Styles
# good guide                https://thevaluable.dev/zsh-completion-guide-examples/
#-------------------------------------------------------------------------------

#-GENERAL-----------------------------------------------------------------------

# use visual menu for selections
zmodload -i zsh/complist
zstyle ':completion:*' menu select

# enable zsh completions (needs to be after zstyle activating menu-select)
autoload compinit -Uz && compinit
[[ $(uname -p) == "i386" ]] && compaudit | xargs chmod g-w # FIX for Intel Mac, https://github.com/zsh-users/zsh-completions/issues/433#issuecomment-629539004

# HOMEBREW: load completions
# load various completions of clis installed via homebrew
# needs to be run *before* compinit/zsh-autocomplete
export FPATH="$ZDOTDIR/completions:$HOMEBREW_PREFIX/share/zsh/site-functions:$FPATH"

# do not save in public dotfile repo
export ZSH_COMPDUMP="$HOME/.local/share/zsh/zcompdump"

#-SORT--------------------------------------------------------------------------

# sort by modification date and follow symlinks
zstyle ':completion:*' file-sort modification follow

# group results
zstyle ':completion:*' group-name ''

# show cd-path ("path-directories") first
zstyle ':completion:*:cd:*' group-order path-directories directories

# show aliases & functions before commands
zstyle ':completion:*:*:-command-:*:*' group-order alias functions builtins commands

# order row-wise, not column-wise
zstyle ':completion:*' list-rows-first true

#-FORMAT & COLOR------------------------------------------------------------------

# warnings and messages
zstyle ':completion:*:messages' format '%F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format '%K{yellow}%F{black}No matches found.%f%k'

# color completion groups with purple-gray background
zstyle ':completion:*:descriptions' format $'\e[7;38;5;103m %d \e[0;38;5;103m\e[0m'

# color items in specific groups (here: aliases in magenta)
zstyle ':completion:*:aliases' list-colors '=*=35'

# 1. option descriptions in gray (`38;5;245` is visible in dark and light mode)
# 2. apply LS_COLORS to files/directories
# 3. selected item (styled via `ma=`)
zstyle ':completion:*:default' list-colors \
	'=(#b)*(-- *)=39=38;5;245' \
	"$LS_COLORS" \
	"ma=7;38;5;68"

#-BINDINGS----------------------------------------------------------------------

# TAB: On empty buffer opens `cd` completion, otherwise next item
# (This is better than `AUTO_CD`, since `zstyle ':completion:*' group-order` does
# not affect `AUTO_CD`, but affects normal `cd`, which we emulate here. )
_tab-on-empty-buffer() {
	# source: https://stackoverflow.com/a/29103676/22114136
	if [[ -z "$BUFFER" && "$CONTEXT" == "start" ]]; then
		BUFFER="cd "
		export CURSOR=3
	fi
	zle menu-complete # open completion and pre-select 1st item
}
zle -N _tab-on-empty-buffer
bindkey '^I' _tab-on-empty-buffer

# SHIFT+TAB: prev item
bindkey '^[[Z' reverse-menu-complete

# SHIFT+RETURN: accept and execute
_accept-and-execute() {
	zle .accept-line
	[[ -z "$BUFFER" ]] || zle .accept-line
}
zle -N _accept-and-execute
bindkey '^J' _accept-and-execute
