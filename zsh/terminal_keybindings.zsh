#───────────────────────────────────────────────────────────────────────────────
# CUSTOM WIDGETS
# https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/copybuffer/copybuffer.plugin.zsh
function copy_buffer {
	# shellcheck disable=2153
	printf "%s" "$BUFFER" | pbcopy
	zle -M "Buffer copied."
}
zle -N copy_buffer

function copy_location {
	pwd | pbcopy
	zle -M "'$PWD' copied."
}
zle -N copy_location

# Cycle through Directories
function grappling_hook {
	local to_open="$WD"
	if [[ "$PWD" == "$WD" ]]; then
		to_open="$HOME/.config"
	elif [[ "$PWD" == "$HOME/.config" ]]; then
		to_open="$VAULT_PATH"
	elif [[ "$PWD" == "$VAULT_PATH" ]]; then
		to_open="$WD"
	fi
	cd "$to_open" || return 1

	wezterm set-working-directory # so wezterm knows we are in a new directory
	zle reset-prompt
}
zle -N grappling_hook

#───────────────────────────────────────────────────────────────────────────────
# INFO BINDINGS FOR WIDGETS
# - use `ctrl-v` and then a key combination to get the shell binding
# - `bindkey -M main` to show existing keybinds
# - some bindings with '^' are reserved (^M=enter, ^I=tab, ^[[Z = shift+tab)
#───────────────────────────────────────────────────────────────────────────────

# needs to be wrapped to not be overwritten by zsh-vi-mode
function zvm_after_init {
	bindkey -M viins '^P' copy_location
	bindkey -M viins '^B' copy_buffer
	bindkey -M viins "^O" grappling_hook  # bound to cmd+enter via wezterm
	bindkey -M viins "…" insert-last-word # …=alt+.
	bindkey -M viins "^Z" undo            # cmd+z via wezterm
	bindkey -M viins "^U" kill-whole-line # whole line, not part of the line

	# DOCS https://zsh.sourceforge.io/Doc/Release/Zsh-Line-Editor.html#Miscellaneous
	# When confirming a command, search history for it and fill buffer with
	# following command. e.g., using `<up><up><up><C-l><C-l><C-l>` will rerun
	# three commands. Similar Alternative: accept-line-and-down-history
	bindkey '^L' accept-and-infer-next-history

	# Plugin Bindings
	bindkey -M viins '^[[A' history-substring-search-up # up/down: history substring search
	bindkey -M viins '^[[B' history-substring-search-down
}

#───────────────────────────────────────────────────────────────────────────────

# when typing bangs or backticks, escape them
function autoEscapeBackTick { LBUFFER+='\`'; }
zle -N autoEscapeBackTick
bindkey -M viins '`' autoEscapeBackTick

function autoEscapeBang { LBUFFER+='\!'; }
zle -N autoEscapeBang
bindkey -M viins '!' autoEscapeBang
