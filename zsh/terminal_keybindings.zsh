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
# INFO BINDINGS FOR WIDGETS
# - use `ctrl-v` and then a key combination to get the shell binding
# - `bindkey -M main` to show existing keybinds
# - some bindings with '^' are reserved (^M=enter, ^I=tab, ^[[Z = shift+tab)
#───────────────────────────────────────────────────────────────────────────────

# needs to be wrapped to not be overwritten by zsh-vi-mode
function zvm_after_init {
	bindkey -M viins '^P' _copy_location
	bindkey -M viins '^B' _copy_buffer
	bindkey -M viins "…" insert-last-word # …=alt+.
	bindkey -M viins "^Z" undo            # cmd+z via wezterm
	bindkey -M viins "^U" kill-whole-line # whole line, not part of the line

	# DOCS https://zsh.sourceforge.io/Doc/Release/Zsh-Line-Editor.html#Miscellaneous
	# When confirming a command, search history for it and fill buffer with
	# following command. e.g., using `<up><up><up><C-l><C-l><C-l>` will rerun
	# three commands. Similar Alternative: accept-line-and-down-history
	bindkey '^L' accept-and-infer-next-history

	# zsh-history-substring-search
	bindkey -M viins '^[[A' history-substring-search-up # up-arrow
	bindkey -M viins '^[[B' history-substring-search-down # down-arrow
}

#───────────────────────────────────────────────────────────────────────────────

# when typing backticks, escape & pair them
function _autoEscapeBackTick {
	LBUFFER+='\`'
	RBUFFER+='\`'
}
zle -N _autoEscapeBackTick
bindkey -M viins '`' _autoEscapeBackTick
