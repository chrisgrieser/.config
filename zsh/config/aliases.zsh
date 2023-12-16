# INFO leading space to ignore it in history due to HIST_IGNORE_SPACE
alias r=' exec zsh' # do not reload with source ~/.zshrc, https://github.com/ohmyzsh/ohmyzsh/wiki/FAQ#how-do-i-reload-the-zshrc-file
alias q=' exit'
alias cmd='command'

# added verbosity / safety
alias mv='mv -vi'
alias ln='ln -vwi'
alias cp='cp -vi'
alias rm='rm -vI'

# defaults
alias grep='grep --color'
alias ls='ls --color'
alias mkdir='mkdir -p' # create intermediate directories
alias curl='curl --progress-bar'
alias make='make --silent --warn-undefined-variables'
alias jless='jless --no-line-numbers'
alias l='eza --all --long --time-style=relative --no-user --smart-group \
	--total-size --no-quotes --git-ignore --sort=newest --hyperlink'

# colorized & showing all
function which { builtin which -a "$@" | bat --language=sh; }

# bat: dark-mode aware
function bat {
	local theme # list themes via `bat --list-themes`
	theme="$(defaults read -g AppleInterfaceStyle &>/dev/null && echo "Dracula" || echo "GitHub")"
	command bat --theme="$theme" "$@"
}

# misc
alias size="du -sh . ./* ./.* | sort -rh | sed 's/\\.\\///'" # size of files in current directory
alias prose='ssh nanotipsforvim@prose.sh'
alias bkp='zsh "$HOME/.config/+ utility-scripts/full-backup.sh"'
alias bkp-repos='zsh "$HOME/.config/+ utility-scripts/backup-my-repos.sh"'

#───────────────────────────────────────────────────────────────────────────────
# https://www.thorsten-hans.com/5-types-of-zsh-aliases

# GLOBAL ALIAS (to be used at the end, mostly)
alias -g G='| rg'
alias -g B='| bat'
alias -g C='| pbcopy ; echo "Copied."' # copy
alias -g N='| wc -l | tr -d " "'       # count lines
alias -g L='| less'
alias -g J='| jless'
alias P='pbpaste > '

# highlights for them
ZSH_HIGHLIGHT_REGEXP+=(' G($| )' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' C$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' B$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' N$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' L$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' J?$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=('^P ' 'fg=magenta,bold')

#───────────────────────────────────────────────────────────────────────────────
