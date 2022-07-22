# Enable vi mode
# shellcheck disable=SC1085,SC1073,SC1009
bindkey -v

function zle-keymap-select () {
    case $KEYMAP in
    ¦   vicmd) echo -ne '\e[1 q';;      # block
    ¦   viins|main) echo -ne '\e[5 q';; # beam
    esac
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.

#-------------------------------------------------------------------------------
bindkey "^P" copyLocation
bindkey "^B" copyBuffer

bindkey "^Z" undo
bindkey "^K" kill-line
bindkey "^V" yank # pastes content previously removed with 'kill-line'

# [alt+arrow] - move word forward or backward
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

# plugins
bindkey '^I' autosuggest-execute # tab: auto-completion & execution from zsh-autosuggest
bindkey '^[[Z' autosuggest-accept # shift+tab: only auto-completion
# bindkey '^[[Z' complete-word   # shift+tab: completion suggestion
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
