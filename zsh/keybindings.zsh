# built in zle functions
bindkey "^A" beginning-of-buffer-or-history
bindkey "^E" end-of-buffer-or-history
bindkey "^Z" undo
bindkey "^Y" redo
bindkey "^K" kill-line
bindkey "^U" vi-kill-line

# custom ZLE funtions
bindkey "^P" copyLocation
bindkey "^B" copyBuffer
bindkey '“' quote-args # alt+2 → quote all args

# [alt+arrow] - move word forward or backward (like on Mac)
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

# zsh-autosuggest
bindkey '^X' autosuggest-execute # e[x]ecute
bindkey '^Y' autosuggest-accept # [y]ank the completion

#-------------------------------------------------------------------------------
# `bindkey -M main` to show existing keybinds
# there `^[` usually means escape
# some bindings with '^' are reserved (^M=enter, ^I=tab, ^[[Z = shift+tab)
# INFO: use ctrl-v and then a key combination to get the shell binding for the
#-------------------------------------------------------------------------------

copyLocation () {
	pwd | pbcopy
	zle -M "'$PWD' copied."
}
zle -N copyLocation

# https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/copybuffer/copybuffer.plugin.zsh
copyBuffer () {
	printf "%s" "$BUFFER" | pbcopy
	zle -M "Buffer copied."
}
zle -N copyBuffer

quote-args() {
    BUFFER="$(echo "$BUFFER" | sed 's/ / "/' | sed 's/$/"/' )"
}
zle -N quote-args
