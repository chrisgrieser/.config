# Good primer on how to bind hotkeys in the ZSH
# https://thevaluable.dev/zsh-line-editor-configuration-mouseless/
#───────────────────────────────────────────────────────────────────────────────

# ENABLE VI MODE
bindkey -v
export KEYTIMEOUT=1

#───────────────────────────────────────────────────────────────────────────────
# INFO: Display all commands for Normal/Insert Mode
# bindkey -M [vicmd|viins|visual]
# use ctrl-v and then a key combination to get the shell binding for the
#───────────────────────────────────────────────────────────────────────────────

bindkey -M vicmd 'L' vi-end-of-line
bindkey -M vicmd 'H' vi-first-non-blank
bindkey -M vicmd 'U' redo
bindkey -M vicmd 'M' vi-join

# to prevent accidentally going to the beginning of the history (which is never
# a desired behavior…) Not implemented for 'G', since going down the history
# is useful
bindkey -M vicmd 'gg' vi-beginning-of-line

bindkey "^?" backward-delete-char # fix backspace
bindkey -M vicmd -s 'Y' 'y$' # -s flag sends direct keystrokes, to allow for remappings
bindkey -M vicmd -s 'X' 'mz$"_x`z' # Remove last character from line

bindkey -M vicmd -s ' ' 'ciw'
# shift-space has to be bound to daw via Karabiner, since the shell does not understand <S-Space>

bindkey -M vicmd -s '?' "ibindkey -M vicmd;bindkey -M viins^M" # this properly re-shows the prompt after execution

# yank to system clipboard – https://stackoverflow.com/a/37411340
# equivalent to `set clipboard=unnamed` (but only for y)
function vi-yank-pbcopy {
	zle vi-yank
	echo "$CUTBUFFER" | pbcopy
}
zle -N vi-yank-pbcopy
bindkey -M vicmd 'y' vi-yank-pbcopy

# q in normal mode exists the Terminal
function normal-mode-exit { exit ; }
zle -N normal-mode-exit
bindkey -M vicmd 'q' normal-mode-exit

#-------------------------------------------------------------------------------
# quote textobjs (i" i' i` i") https://github.com/zsh-users/zsh/blob/master/Functions/Zle/select-quoted
autoload -U select-quoted
zle -N select-quoted
for m in visual viopp; do
	for c in {a,i}{\',\",\`}; do
		bindkey -M $m $c select-quoted
	done
done

# bracket textobjs (i{ i( i[ https://github.com/zsh-users/zsh/blob/master/Functions/Zle/select-bracketed
autoload -U select-bracketed
zle -N select-bracketed
for m in visual viopp; do
	for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
		bindkey -M $m $c select-bracketed
	done
done

#───────────────────────────────────────────────────────────────────────────────

# INFO: prompt styling based on vi mode in starship config
# possible, but not compatible when using the snippet to style the cursor
# do not change cursor for Terminus, since it does not work there, but use
# starship config there instead to indicate vim mode

# numbers in: '\e[1 q'
# Ps = 0 -> blinking block
# Ps = 1 -> blinking block (default)
# Ps = 2 -> steady block
# Ps = 3 -> blinking underline
# Ps = 4 -> steady underline
# Ps = 5 -> blinking bar (xterm)
# Ps = 6 -> steady bar (xterm)

# INFO does not work with xterm, therefore using starship indicator instead
[[ "$TERM_PROGRAM" == "WezTerm" || "$TERM" == "alacritty" ]] || return 0

function zle-keymap-select () {
		case $KEYMAP in
			vicmd) echo -ne '\e[1 q';;      # block
			viins|main) echo -ne '\e[5 q';; # beam
		esac
}
zle -N zle-keymap-select
zle-line-init() {
		zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
		echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt. Use beam shape cursor on startup.


