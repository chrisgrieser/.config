# Enable vi mode
bindkey -v

# Change cursor shape for different vi modes, by @Jack of some quantity of trades
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

#-------------------------------------------------------------------------------

# ℹ️ prompt styling based on vi mode in starship config
# possible, but not compatible when using the snippet to style the cursor

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

# fix backspace
bindkey "^?" backward-delete-char

# in hundredth's of seconds (default: 0.4 seconds)
export KEYTIMEOUT=1

#-------------------------------------------------------------------------------
# Display all commands for Normal/Insert Mode
# bindkey -M vicmd
# bindkey -M viins
bindkey -M vicmd 'L' vi-end-of-line
bindkey -M vicmd 'H' vi-first-non-blank
bindkey -M vicmd 'U' redo
bindkey -M vicmd ' ' '"ciw"'
bindkey -M vicmd 'Y' "y\$"
bindkey -M vicmd '-' vi-history-search-backward
bindkey -M vicmd '?' show-vim-commands

show-vim-commands () {
	bindkey -M vicmd
}
zle -N show-vim-commands
