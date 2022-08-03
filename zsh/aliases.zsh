# shellcheck disable=SC2139
# https://www.thorsten-hans.com/5-types-of-zsh-aliases

# configurations
alias .star='open $STARSHIP_CONFIG'

# beautify JSON in the terminal (yq = better jq)
# e.g.: curl -s "https://api.corona-zahlen.org/germany" | yq -p=yaml -o=json
alias jq='yq -p=yaml -o=json'

# z & cd
alias zz='z -' # back
alias .="open ."
alias ..="z .."
alias ...="z ../.."
alias ....="z ../../.."
alias v='cd "$VAULT_PATH"' # Obsidian Vault

# utils
alias q='exit'
alias notify="osascript -e 'display notification \"\" with title \"Terminal Process finished.\" subtitle \"\" sound name \"\"'"
alias t="alacritty-theme-switch"

# colorize by default
alias grep='grep --color'
alias ls='ls -G'

# Safety nets
alias rm='rm -vI' # -I only asks when more then 3 files are being deleted
alias mv='mv -vi'
alias ln='ln -v'
alias cp='cp -v'

# defaults
alias which='which -a'
alias mkdir='mkdir -p'
alias pip="pip3"

# exa
# these two as functions, so they can be called by other functions
function exa (){
	command exa --all --icons --group-directories-first --sort=modified --ignore-glob=.DS_Store
}
function exagit (){
	git status --short; echo; exa --long --grid --git --git-ignore --no-user --no-permissions --no-time --no-filesize --ignore-glob=.git
}

alias ll='exa --all --long --git --icons --group-directories-first --sort=modified'
alias tree='exa --tree -L2'
alias treee='exa --tree -L3'
alias treeee='exa --tree -L4'
alias treeeee='exa --tree -L5'
alias size="du -sh ./* | sort -rh | sed 's/\\.\\///'" # size of files in current directory

# Suffix Aliases
# = default command to act upon the filetype, when is is entered
# without preceding command (analogous to `setopt AUTO_CD` but for files)
alias -s {css,ts,js,yml,json,plist,xml,md}='bat'
alias -s {pdf,png,jpg,jpeg}="qlmanage -p"

# open log files in less and scrolled to the bottom
alias -s log="less +G"
