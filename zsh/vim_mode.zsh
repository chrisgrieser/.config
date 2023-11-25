# shellcheck disable=2034
#───────────────────────────────────────────────────────────────────────────────

# DOCS https://github.com/jeffreytse/zsh-vi-mode#configuration-function
function zvm_config {
	ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT # Always starting in insert mode
	ZVM_KEYTIMEOUT=0.03 # lower delay for escape

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

# yank to system clipboard – https://stackoverflow.com/a/37411340
# equivalent to `set clipboard=unnamed` (but only for y)
function _vi_yank_pbcopy {
	zle vi-yank # still perform vim-yank for pasting via `p`
	echo "$CUTBUFFER" | pbcopy
}
zle -N _vi_yank_pbcopy

function _vi_delete_pbcopy {
	zle vi-delete
	echo "$CUTBUFFER" | pbcopy
}
zle -N _vi_delete_pbcopy


#───────────────────────────────────────────────────────────────────────────────

# DOCS vi-mode widgets https://github.com/jeffreytse/zsh-vi-mode#custom-widgets-and-keybindings
function zvm_after_lazy_keybindings {
	# disable accidentally searching history search
	bindkey -M vicmd 'k' up-line
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
