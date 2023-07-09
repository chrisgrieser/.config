# shellcheck disable=2034
#───────────────────────────────────────────────────────────────────────────────
# INFO
# available vi-mode widgets: `bindkey -M vicmd`
# zsh-vi-mode config: https://github.com/jeffreytse/zsh-vi-mode#configuration-function
#───────────────────────────────────────────────────────────────────────────────

function zvm_config() {
	ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT # Always starting with insert mode for each command line
	ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BEAM
	ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BLOCK
	ZVM_OPPEND_MODE_CURSOR=$ZVM_CURSOR_BLINKING_UNDERLINE
}

function zvm_after_lazy_keybindings() {
	# zvm_define_widget my_custom_widget

	bindkey -M vicmd 'L' vi-end-of-line
	bindkey -M vicmd 'H' vi-first-non-blank
	bindkey -M vicmd 'U' redo
	bindkey -M vicmd 'M' vi-join

	bindkey -M vicmd 'gg' vi-beginning-of-line # so gg does not go to the top of history
	bindkey -M vicmd -s 'Y' 'y$'               # -s flag sends direct keystrokes, to allow for remappings
	bindkey -M vicmd -s 'X' 'mz$"_x`z'         # Remove last character from line
	bindkey -M vicmd -s ' ' 'ciw'
	bindkey -M vicmd -s '^W' 'daw' # set via Karabiner to <S-Space>
}
