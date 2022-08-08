# shellcheck disable=SC2086,SC2164

# built-in zle functions
bindkey -M viins "^A" beginning-of-line
bindkey -M viins "^E" end-of-line
bindkey -M viins "^Z" undo
bindkey -M viins "^Y" redo
bindkey -M viins "^K" kill-line
bindkey -M viins "^U" kill-whole-line

# custom ZLE funtions
function bindEverywhere () {
	bindkey -M emacs "$1" $2
	bindkey -M viins "$1" $2
	bindkey -M vicmd "$1" $2
}
bindEverywhere "^P" copy-location
bindEverywhere "^B" copy-buffer
bindEverywhere '“' quote-all-args # “=alt+2
bindEverywhere '…' insert-last-word # “=alt+.

# [f]orward to editor
autoload edit-command-line; zle -N edit-command-line
bindEverywhere '^F' edit-command-line

# zsh-autosuggest
bindkey -M viins '^X' autosuggest-execute # e[x]ecute
bindkey -M viins '^[[Z' autosuggest-accept # shift+tab

# shift+tab: Cycle through base directories
bindEverywhere "^[[Z" dir-cycler

#-------------------------------------------------------------------------------
# INFO: use ctrl-v and then a key combination to get the shell binding
# `bindkey -M main` to show existing keybinds
# some bindings with '^' are reserved (^M=enter, ^I=tab, ^[[Z = shift+tab)
#-------------------------------------------------------------------------------

copy-location () {
	pwd | pbcopy
	zle -M "'$PWD' copied."
}
zle -N copy-location

# https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/copybuffer/copybuffer.plugin.zsh
copy-buffer () {
	printf "%s" "$BUFFER" | pbcopy
	zle -M "Buffer copied."
}
zle -N copy-buffer

quote-all-args() {
	if [[ "$BUFFER" =~ " " ]] ; then
		BUFFER="$(echo "$BUFFER" | sed 's/ / "/' | sed 's/$/"/' )"
	else
		BUFFER="\"$BUFFER\""
	fi
}
zle -N quote-all-args

function dir-cycler () {
	if [[ "$PWD" == "$WD" ]]; then
		echo
		z "$DOTFILE_FOLDER"
	else
		echo
		z "$WD"
	fi
	zle reset-prompt
}
zle -N dir-cycler


