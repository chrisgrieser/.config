# INFO
# - use `ctrl-v` or `cat -v` and then a key combination to get the shell binding
# - `bindkey -M main` to show existing keybinds
# - some bindings with '^' are reserved (^M=enter, ^I=tab)
# - available built-in widgets https://zsh.sourceforge.io/Doc/Release/Zsh-Line-Editor.html#Standard-Widgets
#───────────────────────────────────────────────────────────────────────────────
# CUSTOM KEYBINDINGS

# ctrl+u -> cut whole buffer
function _cut-buffer {
	echo -n -- "$BUFFER" | pbcopy
	BUFFER="" # clears whole buffer, rather than just the line via `kill-whole-line`
}
zle -N _cut_buffer
bindkey '^U' _cut_buffer
bindkey -M vicmd -s '^U' 'i^U' # make it work in normal mode as well

# ctrl+p -> copy `PWD` to clipboard
function _copy-location {
	echo -n "$PWD" | pbcopy
	zle -M "Copied: $PWD"
}
zle -N _copy_location
bindkey '^P' _copy_location

# ctrl+z -> unsuspend (nvim/fzf configured to suspend with it)
function _unsuspend { fg; }
zle -N _unsuspend
bindkey '^Z' _unsuspend

# ctr+f -> edit in cmdline
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^F' edit-command-line

# remappings
bindkey '…' insert-last-word    # `alt+.` on macOS
bindkey '^N' undo               # remapped to `cmd+z` via wezterm
bindkey "^[[1;3D" backward-word # `alt+arrow` to move between words (emulating macOS default behavior)
bindkey "^[[1;3C" forward-word
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line

#───────────────────────────────────────────────────────────────────────────────
# VI MODE
bindkey -v # enable vi mode
export KEYTIMEOUT=1 # no delay when pressing <Esc>

# CURSOR SHAPE depending on mode -> https://unix.stackexchange.com/a/614203
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

#───────────────────────────────────────────────────────────────────────────────
# VIM BINDINGS

bindkey -M vicmd 'k' up-line               # disable accidentally searching history
bindkey -M viins '^?' backward-delete-char # FIX backspace

bindkey -M vicmd 'L' vi-end-of-line
bindkey -M vicmd 'H' vi-first-non-blank

bindkey -M vicmd -s ' ' 'ciw' # -s flag sends direct keystrokes and therefore allows for remappings
bindkey -M vicmd 'U' redo
bindkey -M vicmd 'm' vi-join
bindkey -M vicmd -s 'Y' 'y$'

#───────────────────────────────────────────────────────────────────────────────
# YANK/DELETE to (macOS) system clipboard

function _vi_yank_pbcopy { zle vi-yank; print -n -- "$CUTBUFFER" | pbcopy; }
zle -N _vi_yank_pbcopy
bindkey -M vicmd 'y' _vi_yank_pbcopy

function _vi-kill-eol { zle vi-kill-eol; print -n -- "$CUTBUFFER" | pbcopy; }
zle -N _vi-kill-eol
bindkey -M vicmd 'D' _vi-kill-eol

function _vi_delete_pbcopy { zle vi-delete; print -n -- "$CUTBUFFER" | pbcopy; }
zle -N _vi_delete_pbcopy
bindkey -M vicmd 'd' _vi_delete_pbcopy

#───────────────────────────────────────────────────────────────────────────────
# ADD VIM TEXT OBJECTS
autoload -U select-bracketed && zle -N select-bracketed

# CAVEAT cannot be removed to other keys (i.e., there is no `onmap`)
# shellcheck disable=2296
for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
	bindkey -M viopp "$c" select-bracketed
done

autoload -U select-quoted && zle -N select-quoted
for c in {a,i}{\',\",\`}; do
	bindkey -M viopp "$c" select-quoted
done
