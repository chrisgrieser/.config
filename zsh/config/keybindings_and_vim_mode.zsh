# CUSTOM WIDGETS
# make yank, delete, and killing line work with system clipboard
function _vi_yank_pbcopy {
	echo "$CUTBUFFER" | pbcopy
	zle vi-yank # still perform vim-yank for pasting via `p`
}
zle -N _vi_yank_pbcopy

function _vi_delete_pbcopy {
	echo "$CUTBUFFER" | pbcopy
	zle vi-delete
}
zle -N _vi_delete_pbcopy

function _cut_buffer {
	echo -n "$BUFFER" | pbcopy
	BUFFER="" # clears whole buffer, rather than just the line via `kill-whole-line`
}
zle -N _cut_buffer

function _copy_location {
	echo "$PWD" | pbcopy
	zle -M "Copied: $PWD"
}
zle -N _copy_location

#───────────────────────────────────────────────────────────────────────────────
# KEYBINDINGS

# INFO
# - use `ctrl-v` and then a key combination to get the shell binding
# - `bindkey -M main` to show existing keybinds
# - some bindings with '^' are reserved (^M=enter, ^I=tab)
# - all docs can be found here: https://zsh.sourceforge.io/Doc/Release/Zsh-Line-Editor.html#Standard-Widgets

bindkey -M viins '^P' _copy_location
bindkey -M viins '^U' _cut_buffer
bindkey -M vicmd '^U' _cut_buffer

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M viins '…' insert-last-word
bindkey -M viins '^Z' undo # remapped to `cmd+z` via wezterm

autoload -U edit-command-line && zle -N edit-command-line
bindkey -M viins '^F' edit-command-line

#───────────────────────────────────────────────────────────────────────────────
# VIM MODE

export KEYTIMEOUT=1 # no delay when pressing a esc

bindkey -M vicmd 'k' up-line # disable accidentally searching history

bindkey -M vicmd 'L' vi-end-of-line
bindkey -M vicmd 'H' vi-first-non-blank

bindkey -M vicmd -s ' ' 'ciw' # -s flag sends direct keystrokes and therefore allows for remappings
bindkey -M vicmd 'U' redo
bindkey -M vicmd 'M' vi-join

# so it copies to the system clipboard
bindkey -M vicmd 'y' _vi_yank_pbcopy
bindkey -M vicmd 'd' _vi_delete_pbcopy
