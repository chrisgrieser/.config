# shellcheck disable=SC2086

# built-in zle functions
bindkey "^A" beginning-of-buffer-or-history
bindkey "^E" end-of-buffer-or-history
bindkey "^Z" undo
bindkey "^Y" redo
bindkey "^K" kill-line
bindkey "^U" vi-kill-line

# custom ZLE funtions
function bindEverywhere () {
	bindkey -M emacs "$1" $2
	bindkey -M viins "$1" $2
	bindkey -M vicmd "$1" $2
}
bindEverywhere "^P" copy-location
bindEverywhere "^B" copy-buffer
bindEverywhere '“' quote-all-args # “=alt+2

# [f]orward to editor
autoload edit-command-line; zle -N edit-command-line
bindEverywhere '^F' edit-command-line

# zsh-autosuggest
bindkey '^X' autosuggest-execute # e[x]ecute
bindkey '^Y' autosuggest-accept # [y]ank the completion

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
