# shellcheck disable=2034
#───────────────────────────────────────────────────────────────────────────────

# https://github.com/jeffreytse/zsh-vi-mode#configuration-function
function zvm_config {
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

# has to run *after* zvm_config, but *before* zvm_after_lazy_keybindings
vi_plugin="$(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
# shellcheck disable=1090
[[ -f "$vi_plugin" ]] && source "$vi_plugin"

#───────────────────────────────────────────────────────────────────────────────

# available vi-mode widgets: `bindkey -M vicmd`
# https://github.com/jeffreytse/zsh-vi-mode#custom-widgets-and-keybindings

# yank to system clipboard – https://stackoverflow.com/a/37411340
# equivalent to `set clipboard=unnamed` (but only for y)
function vi_yank_pbcopy {
	zle vi-yank # still perform vim-yank for pasting via `p`
	echo "$CUTBUFFER" | pbcopy
}

# q in normal mode exists the Terminal
function normal_mode_exit { exit; }

zle -N vi_yank_pbcopy
zle -N normal_mode_exit

#───────────────────────────────────────────────────────────────────────────────

function zvm_after_lazy_keybindings {
	bindkey -M vicmd 'L' vi-end-of-line
	bindkey -M vicmd 'H' vi-first-non-blank
	bindkey -M vicmd 'U' redo
	bindkey -M vicmd 'M' vi-join
	bindkey -M vicmd 'm' zvm_move_around_surround

	bindkey -M vicmd 'gg' vi-beginning-of-line # so gg does not go to the top of history, which you never want
	bindkey -M vicmd 'q' normal-mode-exit      # quicker quitting
	bindkey -M vicmd 'y' vi-yank-pbcopy        # so it copies to the system clipboard

	# -s flag sends direct keystrokes and therefore allows for remappings
	bindkey -M vicmd -s 'Y' 'y$'

	bindkey -M vicmd -s '^[OQ' 'daw'   # HACK ^[OQ = F2, set via Karabiner to <S-Space>
	bindkey -M vicmd -s ' ' 'ciw'
}
