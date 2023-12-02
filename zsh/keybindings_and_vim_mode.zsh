# DOCS https://github.com/jeffreytse/zsh-vi-mode#configuration-function
# shellcheck disable=2034
function zvm_config {
	ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT # Always starting in insert mode
	ZVM_KEYTIMEOUT=0.03                 # lower delay for escape

	# cursor styling with blinking
	ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BEAM
	ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BLOCK
	ZVM_OPPEND_MODE_CURSOR=$ZVM_CURSOR_BLINKING_UNDERLINE
	ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_BLINKING_UNDERLINE
	ZVM_VISUAL_LINE_MODE_CURSOR=$ZVM_CURSOR_BLINKING_UNDERLINE
}

#───────────────────────────────────────────────────────────────────────────────

# INFO has to run *after* zvm_config, but *before* zvm_after_lazy_keybindings
# shellcheck disable=1091
source "$HOMEBREW_PREFIX/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"

#───────────────────────────────────────────────────────────────────────────────

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
# DEFINE KEYBINDINGS

# INFO
# - use `ctrl-v` and then a key combination to get the shell binding
# - `bindkey -M main` to show existing keybinds
# - some bindings with '^' are reserved (^M=enter, ^I=tab)

# needs to be wrapped to not be overwritten by zsh-vi-mode
function zvm_after_init {
	bindkey -M viins '^P' _copy_location
	bindkey -M viins '^U' _cut_buffer
	bindkey -M viins '…' insert-last-word
}

# DOCS vi-mode widgets https://github.com/jeffreytse/zsh-vi-mode#custom-widgets-and-keybindings
function zvm_after_lazy_keybindings {
	bindkey -M vicmd 'k' up-line # disable accidentally searching history
	bindkey -M vicmd 'gg' up-line

	bindkey -M vicmd 'L' vi-end-of-line
	bindkey -M vicmd 'H' vi-first-non-blank

	bindkey -M vicmd -s 'Y' 'y$' # -s flag sends direct keystrokes and therefore allows for remappings
	bindkey -M vicmd -s ' ' 'ciw'
	bindkey -M vicmd 'U' redo
	bindkey -M vicmd 'M' vi-join
	bindkey -M vicmd 'm' zvm_move_around_surround
	bindkey -M vicmd 'qq' vi-pound-insert # = toggle comment

	# so it copies to the system clipboard
	bindkey -M vicmd 'y' _vi_yank_pbcopy
	bindkey -M vicmd 'd' _vi_delete_pbcopy
}
