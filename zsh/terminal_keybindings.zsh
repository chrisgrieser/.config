# shellcheck disable=SC2086,SC2164

function bindEverywhere () {
	bindkey -M emacs "$1" $2
	bindkey -M viins "$1" $2
	bindkey -M vicmd "$1" $2
}
bindEverywhere "^A" beginning-of-line
bindEverywhere "^B" copy-buffer
bindEverywhere "^E" end-of-line
bindEverywhere "^U" kill-whole-line
bindEverywhere "^P" copy-location
bindEverywhere "^Z" undo # wezterm: cmd+z
bindEverywhere "…" insert-last-word # …=alt+.

bindEverywhere '^[[A' history-substring-search-up # up/down: history substring search
bindEverywhere '^[[B' history-substring-search-down 
bindEverywhere "^[[Z" autosuggest-accept # shift-tab: accept ghost text from zsh-autosugget

# ctrl+O (bound to cmd+enter via wezterm): base directories 
bindEverywhere "^O" harpoon

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

function harpoon () {
	if [[ "$PWD" == "$WD" ]]; then
		cd "$DOTFILE_FOLDER"
	elif [[ "$PWD" == "$DOTFILE_FOLDER" ]]; then
		cd "$VAULT_PATH"
	else
		cd "$WD"
	fi
	zle reset-prompt
}
zle -N harpoon
