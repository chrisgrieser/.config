# z & cd
# INFO leading space to ignore it in history due to HIST_IGNORE_SPACE
alias ..=" z .."
alias ...=" z ../.."

# utils
# INFO leading space to ignore it in history due to HIST_IGNORE_SPACE
alias r=' exec zsh' # do not reload with source ~/.zshrc, https://github.com/ohmyzsh/ohmyzsh/wiki/FAQ#how-do-i-reload-the-zshrc-file
alias q=' exit'
alias c='command'
alias b='bat'

# added verbosity
alias mv='mv -v'
alias ln='ln -v'
alias cp='cp -v'

# defaults
alias grep='grep --ignore-case --color'
alias ls='ls --color'
alias which='which -a'           # show all
alias mkdir='mkdir -p'           # create intermediate directories
alias curl='curl --progress-bar' # nicer progress bar
alias make='make --silent --warn-undefined-variables'

# eza
alias l='eza --all --long --time-style=relative --no-user --git --sort=newest --color-scale=age'
alias tree='eza --tree --level=2 --git-ignore --no-quotes'
alias treee='eza --tree --level=3 --git-ignore --no-quotes'
alias treeee='eza --tree --level=4 --git-ignore --no-quotes'

alias size2='eza --color-scale=size --sort=size --long --no-user --no-permissions --no-time'
alias size="du -sh . ./* ./.* | sort -rh | sed 's/\\.\\///'" # size of files in current directory

# misc
alias prose='ssh nanotipsforvim@prose.sh'
alias bkp='zsh "$HOME/.config/_utility-scripts/backup-script.sh"'
alias repobkp='zsh "$HOME/.config/_utility-scripts/backup-my-repos.sh"'
alias vd="visidata"

#───────────────────────────────────────────────────────────────────────────────
# https://www.thorsten-hans.com/5-types-of-zsh-aliases

# SUFFIX Alias
# shellcheck disable=2139
alias -s {yml,yaml}='yq "."'
alias -s json='command jless --no-line-numbers'
alias -s pdf='qlmanage -p'

[[ "$TERM_PROGRAM" == "WezTerm" ]] && image_viewer="wezterm imgcat" || image_viewer="qlmanage -p"
# shellcheck disable=2139
alias -s {gif,png,jpg,jpeg,webp,tiff}="$image_viewer"

#───────────────────────────────────────────────────────────────────────────────

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
