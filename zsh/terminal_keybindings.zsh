#───────────────────────────────────────────────────────────────────────────────
# CUSTOM WIDGETS
# https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/copybuffer/copybuffer.plugin.zsh
function copy-buffer() {
	# shellcheck disable=2153
	printf "%s" "$BUFFER" | pbcopy
	zle -M "Buffer copied."
}
zle -N copy-buffer

function copy-location() {
	pwd | pbcopy
	zle -M "'$PWD' copied."
}
zle -N copy-location

# kills complete line, instead of just to beginning (^U) or end of a line (^K)
function kill-full-line() {
	zle end-of-line | true
	zle vi-kill-line
}
zle -N kill-full-line

# Cycle through Directories
function grappling-hook() {
	local to_open="$WD"
	if [[ "$PWD" == "$WD" ]]; then
		to_open="$DOTFILE_FOLDER"
	elif [[ "$PWD" == "$DOTFILE_FOLDER" ]]; then
		to_open="$VAULT_PATH"
	elif [[ "$PWD" == "$VAULT_PATH" ]]; then
		to_open="$WD"
	fi
	cd "$to_open" || return 1
	zle reset-prompt
}
zle -N grappling-hook

#───────────────────────────────────────────────────────────────────────────────
# INFO BINDINGS FOR WIDGETS
# - use `ctrl-v` and then a key combination to get the shell binding
# - `bindkey -M main` to show existing keybinds
# - some bindings with '^' are reserved (^M=enter, ^I=tab, ^[[Z = shift+tab)
#───────────────────────────────────────────────────────────────────────────────

# needs to be wrapped to not be overwritten by zsh-vi-mode
function zvm_after_init() {
	bindkey -M viins '^P' copy-location
	bindkey -M viins '^B' copy-buffer
	bindkey -M viins "^O" grappling-hook # bound to cmd+enter via wezterm
	bindkey -M viins "^U" kill-full-line
}
bindkey -M viins "…" insert-last-word # …=alt+.
bindkey -M viins "^Z" undo            # cmd+z via wezterm

# Plugin Bindings
bindkey -M viins '^[[A' history-substring-search-up # up/down: history substring search
bindkey -M viins '^[[B' history-substring-search-down
bindkey -M viins "^X" autosuggest-accept # cmd+s via wezterm (consistent w/ nvim ghost text accept)

#───────────────────────────────────────────────────────────────────────────────

# Escape by default
function autoEscapeBacktick() { LBUFFER+='\`' ; }
zle -N autoEscapeBacktick
bindkey -M viins '`' autoEscapeBacktick

