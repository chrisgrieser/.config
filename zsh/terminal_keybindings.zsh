#───────────────────────────────────────────────────────────────────────────────
# INFO BINDINGS FOR WIDGETS
# - use `ctrl-v` and then a key combination to get the shell binding
# - `bindkey -M main` to show existing keybinds
# - some bindings with '^' are reserved (^M=enter, ^I=tab)
#───────────────────────────────────────────────────────────────────────────────
# CUSTOM WIDGETS
# https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/copybuffer/copybuffer.plugin.zsh
function _copy_buffer {
	# shellcheck disable=2153
	printf "%s" "$BUFFER" | pbcopy
	zle -M "Buffer copied."
}
zle -N _copy_buffer

function _copy_location {
	pwd | pbcopy
	zle -M "'$PWD' copied."
}
zle -N _copy_location

#───────────────────────────────────────────────────────────────────────────────

# needs to be wrapped to not be overwritten by zsh-vi-mode
function zvm_after_init {
	bindkey -M viins '^P' _copy_location
	bindkey -M viins '^B' _copy_buffer
	bindkey -M viins "…" insert-last-word # …=alt+.
	bindkey -M viins "^Z" undo            # cmd+z via wezterm
	bindkey -M viins "^U" kill-whole-line # whole line, not part of the line
}

#───────────────────────────────────────────────────────────────────────────────
