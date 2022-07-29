# Good primer on how to bind hotkeys in the ZSH
# https://thevaluable.dev/zsh-line-editor-configuration-mouseless/
#-------------------------------------------------------------------------------

# Enable vi mode
bindkey -v

# fix backspace
bindkey "^?" backward-delete-char

# in hundredth's of seconds (default: 0.4 seconds)
export KEYTIMEOUT=1

#-------------------------------------------------------------------------------
# https://jindalakshett.medium.com/zsh-vim-%EF%B8%8F-eafdef2183c4
# ci", ci', ci`, di", etc
autoload -U select-quoted
zle -N select-quoted
for m in visual viopp; do
	for c in {a,i}{\',\",\`}; do
		bindkey -M $m $c select-quoted
	done
done

# ci{, ci(, ci<, di{, etc
autoload -U select-bracketed
zle -N select-bracketed
for m in visual viopp; do
	for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
		bindkey -M $m $c select-bracketed
	done
done

#-------------------------------------------------------------------------------
# INFO:Display all commands for Normal/Insert Mode
# bindkey -M [vicmd|viins|visual]
# use ctrl-v and then a key combination to get the shell binding for the
#-------------------------------------------------------------------------------

bindkey -M vicmd 'L' vi-end-of-line
bindkey -M vicmd 'H' vi-first-non-blank
bindkey -M vicmd 'U' redo
# -s flag sends direct keystrokes, to allow for remappings
bindkey -M vicmd -s 'Y' 'y$'
bindkey -M vicmd -s ' ' 'ciw'
bindkey -M vicmd -s 'ö' 'xp' # transpose (move character to the right)
bindkey -M vicmd -s 'Ö' 'xhhp' # reversed transpose (move character to the left)
# shift-space has to be bound to daw via alacritty.yml, cause shell does not accept shift-space :(
  # - { key: Space, mods: shift, chars: '^]'}

bindkey -M vicmd -s '?' "ibindkey -M vicmd^M" # this properly re-shows the prompt after execution

#-------------------------------------------------------------------------------

# INFO: prompt styling based on vi mode in starship config
# possible, but not compatible when using the snippet to style the cursor

# Change cursor shape for different vi modes
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
