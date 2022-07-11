# https://www.soberkoder.com/better-zsh-history/

export HISTSIZE=3000
export SAVEHIST=3000
export HISTFILE="$ZSH_DOTFILE_LOCATION"/.zsh_history

setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_VERIFY
setopt EXTENDED_HISTORY

# --------------------------

export HIST_DATE_FORMAT='%a %d.%m %H:%M   ' # custom, defined by me

# SEARCH HISTORY FOR A COMMAND
# enter ➞ write to buffer
# alt+enter ➞ copy to clipboard

DATE_CHAR_COUNT=$(date "+$HIST_DATE_FORMAT" | wc -m | tr -d " ")
TO_CUT=$((DATE_CHAR_COUNT + 2))
function hs {
	SELECTED=$(history -t "$HIST_DATE_FORMAT" 1 | cut -c8- | fzf\
	           --tac --no-sort \
	           --layout=reverse \
	           --info=hidden \
	           --query "$*" \
	           --height=50% \
	           --bind "alt-enter:execute(echo {} | cut -c\"$TO_CUT\"- | pbcopy)+abort" \
	          )
	COMMAND=$(echo "$SELECTED" | cut -c"$TO_CUT"-)
	print -z "$COMMAND" # print to buffer
}
