# SHORTHANDS
alias q=' exit'     # INFO leading space to ignore it in history due to `HIST_IGNORE_SPACE`
alias r=' exec zsh' # do not reload with source ~/.zshrc, https://github.com/ohmyzsh/ohmyzsh/wiki/FAQ#how-do-i-reload-the-zshrc-file
alias cmd='command'
alias spotify="spotify_player playback"
alias j="just"

# DEFAULTS
alias mv='mv -vi'
alias ln='ln -vwis'
alias cp='cp -vi'
alias rm='rm -I'
alias curl='curl --progress-bar'
alias tokei="tokei --compact --exclude='*.txt' --exclude='*.json'"
alias l='eza --all --long --time-style=relative --no-user --total-size \
	--smart-group --no-quotes --git-ignore --sort=newest'

function which { # colorized & showing all
	builtin which -a "$@" | bat --language=sh --wrap=character
}

function bat { # dark-mode aware
	local theme   # list themes via `bat --list-themes`
	theme="$(defaults read -g AppleInterfaceStyle &> /dev/null && echo "Dracula" || echo "Monokai Extended Light")"
	command bat --theme="$theme" "$@"
}

# UTILS
alias sizes_in_cwd="du -sh . ./* | sort -rh | sed 's|\./||'" # size of files in current directory
alias bkp_full='zsh "$HOME/.config/+ utility-scripts/full-backup.sh"'
alias bkp_repos='zsh "$HOME/.config/+ utility-scripts/backup-my-repos.sh"'
alias sync_repo='zsh ./.sync-this-repo.sh'

export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

function cake { mkdir -p "$1" && cd "$1" || return 1; }
function topen { touch "$1" && open "$1"; }

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
