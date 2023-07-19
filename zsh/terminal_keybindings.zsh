#───────────────────────────────────────────────────────────────────────────────
# CUSTOM WIDGETS
# https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/copybuffer/copybuffer.plugin.zsh
function copy-buffer() {
	printf "%s" "$BUFFER" | pbcopy
	zle -M "Buffer copied."
}
zle -N copy-buffer

function copy-location() {
	pwd | pbcopy
	zle -M "'$PWD' copied."
}
zle -N copy-location

function harpoon () {
	if [[ "$PWD" == "$WD" ]]; then
		cd "$DOTFILE_FOLDER" || return 1
	elif [[ "$PWD" == "$DOTFILE_FOLDER" ]]; then
		cd "$VAULT_PATH" || return 1
	else
		cd "$WD" || return 1
	fi
	zle reset-prompt
}
zle -N harpoon


#───────────────────────────────────────────────────────────────────────────────
# BINDINGS FOR WIDGETS
#───────────────────────────────────────────────────────────────────────────────
# INFO: use ctrl-v and then a key combination to get the shell binding
# `bindkey -M main` to show existing keybinds
# some bindings with '^' are reserved (^M=enter, ^I=tab, ^[[Z = shift+tab)
#───────────────────────────────────────────────────────────────────────────────

# needs to be wrapped so not overwritten by zsh-vi-mode
function zvm_after_init() {
	bindkey -M viins '^P' copy-location
	bindkey -M viins '^B' copy-buffer
	bindkey -M viins "^O" harpoon # bound to cmd+enter via wezterm
}
bindkey -M viins "…" insert-last-word # …=alt+.

# Plugin Bindings
bindkey -M viins '^[[A' history-substring-search-up # up/down: history substring search
bindkey -M viins '^[[B' history-substring-search-down 
bindkey -M viins "^[[Z" autosuggest-accept # shift-tab: accept ghost text from zsh-autosugget

