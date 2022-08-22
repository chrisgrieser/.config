# shellcheck disable=SC2139
# https://www.thorsten-hans.com/5-types-of-zsh-aliases

# configurations
alias .star='open $STARSHIP_CONFIG'
alias r='source ~/.zshrc ; echo ".zshrc reloaded"'

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
alias rm='rm -i'
alias mv='mv -i'
alias ln='ln -v'
alias cp='cp -v'

# defaults
alias which='which -a'
alias mkdir='mkdir -p'
alias pip="pip3"
alias curl="curl -s"

# exa
# in function for directoryInspect function
function exa(){
	command exa --all --icons --group-directories-first --sort=modified --ignore-glob=.DS_Store
}

alias exagit='git status --short; echo; exa --long --grid --git --git-ignore --no-user --no-permissions --no-time --no-filesize --ignore-glob=.git'
alias l='command exa --all --long --git --icons --group-directories-first --sort=modified'
alias tree='command exa --tree --icons'
alias size="du -sh . ./* ./.* | sort -rh | sed 's/\\.\\///'" # size of files in current directory

# Global Alias
alias -g H="--help"
alias -g G="| grep --color"

# Suffix Aliases
# = default command to act upon the filetype, when is is entered
# ' and " are there to also open quoted things
# without preceding command (analogous to `setopt AUTO_CD` but for files)
alias -s {css,ts,js,yml,json,plist,xml,md}='bat'
alias -s {css,ts,js,yml,json,plist,xml,md}\"='bat'
alias -s {css,ts,js,yml,json,plist,xml,md}\'='bat'
alias -s {pdf,png,jpg,jpeg,tiff}="qlmanage -p &> /dev/null"
alias -s {pdf,png,jpg,jpeg,tiff}\"="qlmanage -p &> /dev/null"
alias -s {pdf,png,jpg,jpeg,tiff}\'="qlmanage -p &> /dev/null"

# open log files in less and scrolled to the bottom
alias -s log="less +G"
alias -s log\'="less +G"
alias -s log\"="less +G"
