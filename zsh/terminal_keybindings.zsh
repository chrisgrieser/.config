# shellcheck disable=SC2086,SC2164

function bindEverywhere () {
	bindkey -M emacs "$1" $2
	bindkey -M viins "$1" $2
	bindkey -M vicmd "$1" $2
}
bindEverywhere "^A" beginning-of-line
bindEverywhere "^E" end-of-line
bindEverywhere "^U" kill-whole-line
bindEverywhere "^P" copy-location
bindEverywhere "^B" copy-buffer # wezterm: cmd+b
bindEverywhere "^Z" undo # wezterm: cmd+z
bindEverywhere "…" insert-last-word # …=alt+.

# [f]orward to $EDITOR
autoload edit-command-line
zle -N edit-command-line
bindEverywhere "^F" edit-command-line

# accept ghost text from zsh-autosugget
bindEverywhere "^[[Z" autosuggest-accept

# ctrl+O (bound to cmd+enter via wezterm): base directories (Mini-Harpoon)
bindEverywhere "^O" dir-cycler

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

function dir-cycler () {
	if [[ "$PWD/" == "$WD" ]]; then
		cd "$DOTFILE_FOLDER"
	elif [[ "$PWD/" == "$DOTFILE_FOLDER" ]]; then
		cd "$VAULT_PATH"
	else
		cd "$WD"
	fi
	zle reset-prompt
}
zle -N dir-cycler
