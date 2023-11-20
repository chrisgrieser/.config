# INFO leading space to ignore it in history due to HIST_IGNORE_SPACE
alias r=' exec zsh' # do not reload with source ~/.zshrc, https://github.com/ohmyzsh/ohmyzsh/wiki/FAQ#how-do-i-reload-the-zshrc-file
alias q=' exit'
alias cmd='command'

# added verbosity
alias mv='mv -v'
alias ln='ln -v'
alias cp='cp -v'

# defaults
alias grep='grep --ignore-case --color'
alias ls='ls --color'
alias mkdir='mkdir -p' # create intermediate directories
alias curl='curl --progress-bar'
alias make='make --silent --warn-undefined-variables'

# colorized & showing all
function which { builtin which -a "$@" | bat --language=sh; }

# eza
alias l=' eza --all --long --time-style=relative --no-user --smart-group \
	--total-size --no-quotes --git-ignore --sort=newest'
alias tree='eza --tree --level=2 --git-ignore --no-quotes'
alias treee='eza --tree --level=3 --git-ignore --no-quotes'
alias treeee='eza --tree --level=4 --git-ignore --no-quotes'

# bat
function bat {
	command bat --theme="$(defaults read -g AppleInterfaceStyle &>/dev/null && echo Dracula || echo GitHub)" "$@"
}

# misc
alias size="du -sh . ./* ./.* | sort -rh | sed 's/\\.\\///'" # size of files in current directory
alias prose='ssh nanotipsforvim@prose.sh'
alias bkp='zsh "$HOME/.config/_utility-scripts/backup-script.sh"'
alias bkp-repos='zsh "$HOME/.config/_utility-scripts/backup-my-repos.sh"'

#───────────────────────────────────────────────────────────────────────────────
# https://www.thorsten-hans.com/5-types-of-zsh-aliases

# GLOBAL ALIAS (to be used at the end, mostly)
alias -g G='| rg'
alias -g B='| bat'
alias -g C='| pbcopy ; echo "Copied."' # copy
alias -g N='| wc -l | tr -d " "'       # count lines
alias -g J='| command jless --no-line-numbers'

# highlights for them
ZSH_HIGHLIGHT_REGEXP+=(' G$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' G ' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' C$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' B$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' N$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' J$' 'fg=magenta,bold')

#───────────────────────────────────────────────────────────────────────────────
