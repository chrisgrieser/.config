# INFO leading space to ignore it in history due to `HIST_IGNORE_SPACE`
alias r=' exec zsh' # do not reload with source ~/.zshrc, https://github.com/ohmyzsh/ohmyzsh/wiki/FAQ#how-do-i-reload-the-zshrc-file
alias q=' exit'

# added verbosity / safety
alias mv='mv -vi'
alias ln='ln -vwi'
alias cp='cp -vi'
alias rm='rm -I'

# shorthands
alias cmd='command'
alias spotify="spotify_player playback"

# make
alias m="make"
alias make='make --silent --warn-undefined-variables'

# defaults
alias grep='grep --color'
alias mkdir='mkdir -pv' # create intermediate directories & verbose
alias curl='curl --progress-bar'
alias jless='jless --no-line-numbers'
alias tokei="tokei --compact --exclude='*.txt' --exclude='*.json' --num-format=underscores"
function which { builtin which -a "$@" | bat --language=sh --wrap=character; } # colorized & showing all

# dark-mode aware
function bat {
	local theme # list themes via `bat --list-themes`
	theme="$(defaults read -g AppleInterfaceStyle &>/dev/null && echo "Dracula" || echo "Monokai Extended Light")"
	command bat --theme="$theme" "$@"
}

function aider {
	local style
	style="$(defaults read -g AppleInterfaceStyle &>/dev/null && echo "dark" || echo "light")"
	command aider --"$style"-mode "$@"
}

# utils
alias size="du -sh . ./* ./.* | sort -rh | sed 's/\\.\\///'" # size of files in current directory
alias prose='ssh nanotipsforvim@prose.sh'
alias bkp='zsh "$HOME/.config/+ utility-scripts/full-backup.sh"'
alias bkp-repos='zsh "$HOME/.config/+ utility-scripts/backup-my-repos.sh"'

#───────────────────────────────────────────────────────────────────────────────
# GLOBAL ALIAS (to be used at the end of the buffer, mostly)
alias -g G='| rg'
alias -g B='| bat'
alias -g N='| wc -l | tr -d " "' # count lines
alias -g L='| less'
alias -g J='| jless'
alias -g C='| pbcopy ; echo "Copied."' # copy
alias P='pbpaste'                      # paste

# highlights for them
ZSH_HIGHLIGHT_REGEXP+=(' G($| )' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' C$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' B$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' N$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' L$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' J$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=('^P ' 'fg=magenta,bold')

#───────────────────────────────────────────────────────────────────────────────
