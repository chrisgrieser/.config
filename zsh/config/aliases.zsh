# SHORTHANDS
alias q=' exit'     # INFO leading space to ignore it in history due to `HIST_IGNORE_SPACE`
alias r=' exec zsh' # do not reload with source ~/.zshrc, https://github.com/ohmyzsh/ohmyzsh/wiki/FAQ#how-do-i-reload-the-zshrc-file
alias cmd='command'
alias spotify="spotify_player playback"
alias ydl="yt-dlp"
alias m="make"

# DEFAULTS
alias mv='mv -vi'
alias ln='ln -vwis'
alias cp='cp -vi'
alias rm='rm -I'
alias make='make --silent --warn-undefined-variables'
alias mkdir='mkdir -p' # create intermediate directories
alias curl='curl --progress-bar'
alias tokei="tokei --compact --exclude='*.txt' --exclude='*.json'"
alias l='eza --all --long --time-style=relative --no-user \
	--smart-group --no-quotes --git-ignore --sort=newest'

function which { # colorized & showing all
	builtin which -a "$@" | bat --language=sh --wrap=character
}
function bat { # dark-mode aware
	local theme   # list themes via `bat --list-themes`
	theme="$(defaults read -g AppleInterfaceStyle &>/dev/null && echo "Dracula" || echo "Monokai Extended Light")"
	command bat --theme="$theme" "$@"
}

# UTILS
alias size="du -sh . ./* ./.* | sort -rh | sed 's/\\.\\///'" # size of files in current directory
alias bkp='zsh "$HOME/.config/+ utility-scripts/full-backup.sh"'
alias bkp-repos='zsh "$HOME/.config/+ utility-scripts/backup-my-repos.sh"'
alias sync='zsh ./.sync-this-repo.sh'

function cake { mkdir -p "$1" && cd "$1" || return 1; }
function topen { touch "$1" && open "$1"; }
function prose { scp "$1" prose.sh:/; } # https://pico.sh/prose#publish-your-posts-with-one-command

#───────────────────────────────────────────────────────────────────────────────
# GLOBAL ALIAS (to be used at the end of the buffer, mostly)
alias -g G='| rg'
alias -g B='| bat'
alias -g N='| wc -l | tr -d " "' # count lines
alias -g L='| less'
alias -g J='| fx'
alias -g C='| pbcopy ; echo "Copied."'

# highlights for them
ZSH_HIGHLIGHT_REGEXP+=(' G($| )' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' C$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' B$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' N$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' L$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' J$' 'fg=magenta,bold')

#───────────────────────────────────────────────────────────────────────────────
