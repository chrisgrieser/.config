# INFO
# - use `ctrl-v` and then a key combination to get the shell binding
# - `bindkey -M main` to show existing keybinds
# - some bindings with '^' are reserved (^M=enter, ^I=tab)
# - all docs can be found here: https://zsh.sourceforge.io/Doc/Release/Zsh-Line-Editor.html#Standard-Widgets
#───────────────────────────────────────────────────────────────────────────────
# KEYBINDINGS

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

bindkey -M viins '^P' _copy_location
bindkey -M viins '^U' _cut_buffer
bindkey -M vicmd '^U' _cut_buffer

bindkey -M viins '…' insert-last-word
bindkey -M viins '^Z' undo # remapped to `cmd+z` via wezterm

autoload -U edit-command-line && zle -N edit-command-line
bindkey -M viins '^F' edit-command-line

# alt+arrow to move between words (emulating macOS default behavior)
bindkey -M viins "^[[1;3D" backward-word
bindkey -M viins "^[[1;3C" forward-word

bindkey -M viins "^A" beginning-of-line
bindkey -M viins "^E" end-of-line

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

#───────────────────────────────────────────────────────────────────────────────
# VI MODE
bindkey -v
export KEYTIMEOUT=1 # no delay when pressing <Esc>
bindkey -M viins '^?' backward-delete-char # FIX backspace

# CURSOR SHAPE # https://unix.stackexchange.com/a/614203
function zle-keymap-select {
	if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
		echo -ne '\e[1 q'
	elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] ||
		[[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
		echo -ne '\e[5 q'
	fi
}
zle -N zle-keymap-select

_fix_cursor() { echo -ne '\e[5 q'; }
precmd_functions+=(_fix_cursor)

# VIM BINDINGS

bindkey -M vicmd 'k' up-line # disable accidentally searching history

bindkey -M vicmd 'L' vi-end-of-line
bindkey -M vicmd 'H' vi-first-non-blank

bindkey -M vicmd -s ' ' 'ciw' # -s flag sends direct keystrokes and therefore allows for remappings
bindkey -M vicmd 'U' redo
bindkey -M vicmd 'M' vi-join

# YANK/DELETE to (macOS) system clipboard
bindkey -M viins '^?' backward-delete-char # FIX backspace
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

bindkey -M vicmd 'y' _vi_yank_pbcopy
bindkey -M vicmd 'd' _vi_delete_pbcopy
