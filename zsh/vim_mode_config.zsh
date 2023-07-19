# shellcheck disable=2034
#───────────────────────────────────────────────────────────────────────────────

# https://github.com/jeffreytse/zsh-vi-mode#configuration-function
function zvm_config() {
	# Always starting with insert mode for each command line
	ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT

	ZVM_KEYTIMEOUT=0.666 # default: 0.4

	# cursor styling with blinking
	ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BEAM
	ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BLOCK
	ZVM_OPPEND_MODE_CURSOR=$ZVM_CURSOR_BLINKING_UNDERLINE
	ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_BLINKING_UNDERLINE
	ZVM_VISUAL_LINE_MODE_CURSOR=$ZVM_CURSOR_BLINKING_UNDERLINE
}

#───────────────────────────────────────────────────────────────────────────────

# shellcheck disable=1091
# has to run *after* zvm_config, but *before* zvm_after_lazy_keybindings
source "$(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"

#───────────────────────────────────────────────────────────────────────────────

# available vi-mode widgets: `bindkey -M vicmd`
# https://github.com/jeffreytse/zsh-vi-mode#custom-widgets-and-keybindings

# yank to system clipboard – https://stackoverflow.com/a/37411340
# equivalent to `set clipboard=unnamed` (but only for y)
function vi-yank-pbcopy() {
	zle vi-yank # still perform vim-yank for pasting via `p`
	echo "$CUTBUFFER" | pbcopy
}

# q in normal mode exists the Terminal
function normal-mode-exit() { exit; }

zle -N vi-yank-pbcopy
zle -N normal-mode-exit

#───────────────────────────────────────────────────────────────────────────────

function zvm_after_lazy_keybindings() {
	bindkey -M vicmd 'L' vi-end-of-line
	bindkey -M vicmd 'H' vi-first-non-blank
	bindkey -M vicmd 'U' redo
	bindkey -M vicmd 'M' vi-join

	bindkey -M vicmd 'gg' vi-beginning-of-line # so gg does not go to the top of history, which you never want
	bindkey -M vicmd 'q' normal-mode-exit      # quicker quitting
	bindkey -M vicmd 'y' vi-yank-pbcopy        # so it copies to the system clipboard

	# -s flag sends direct keystrokes, to allow for remappings
	bindkey -M vicmd -s 'Y' 'y$'
	bindkey -M vicmd -s 'X' 'mz$"_x`z' # Remove last character from line
	bindkey -M vicmd -s '^S' 'daw'     # HACK set via Karabiner to <S-Space>
	bindkey -M vicmd -s ' ' 'ciw'
}
