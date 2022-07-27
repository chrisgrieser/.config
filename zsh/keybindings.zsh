bindkey "^P" copyLocation
bindkey "^B" copyBuffer

bindkey "^Z" undo
bindkey "^K" kill-line
bindkey "^V" yank # pastes content previously removed with 'kill-line'

# [alt+arrow] - move word forward or backward
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

# plugins
bindkey '^I' autosuggest-accept # tab: only auto-completion
bindkey '^[[Z' autosuggest-execute # shift+tab: auto-completion & execution from zsh-autosuggest
# https://github.com/zsh-users/zsh-autosuggestions/issues/532#issuecomment-907361899

# -----------------------------------
# `bindkey -M main` to show existing keybinds
# there `^[` usually means escape
# some bindings with '^' are reserved (^M=enter, ^I=tab)
# -----------------------------------

copyLocation () {
	pwd | pbcopy
}
zle -N copyLocation

quitSession () {
	exit
}
zle -N quitSession

# https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/copybuffer/copybuffer.plugin.zsh
copyBuffer () {
	printf "%s" "$BUFFER" | pbcopy
}
zle -N copyBuffer
