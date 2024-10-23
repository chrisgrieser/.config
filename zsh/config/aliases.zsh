# SHORTHANDS
alias q=' exit'     # leading space to ignore it in history due to `HIST_IGNORE_SPACE`
alias r=' exec zsh' # do not reload with `source ~/.zshrc`, https://github.com/ohmyzsh/ohmyzsh/wiki/FAQ#how-do-i-reload-the-zshrc-file
alias cmd='command'
alias spotify="spotify_player playback"
alias pw="pass"
alias pwcd='cd "${PASSWORD_STORE_DIR:-$HOME/.password-store}"'

# DEFAULTS
alias mv='mv -vi'
alias ln='ln -vwis'
alias cp='cp -vi'
alias rm='rm -I'
alias vidir='vidir --verbose'
alias curl='curl --progress-bar'
alias tokei="tokei --compact --exclude='*.txt' --exclude='*.json'"
alias zip='zip --recurse-paths --symlinks'

#───────────────────────────────────────────────────────────────────────────────

# EZA
alias e='eza --all --long --time-style=relative --no-user --total-size \
	--smart-group --no-quotes --sort=newest'
alias tree='eza --tree --level=7 --no-quotes --icons=always --color=always | less'

# JUST
alias j="just"
alias ji='just init'
alias jr='just release'
function js { just --show "$1" | bat --language=sh --paging=never; }
# completions for it
_just_recipes() {
	IFS=" " read -r -A recipes <<< "$(just --summary --unsorted)"
	local expl && _description -V all-recipes expl 'Just Recipes'
	compadd "${expl[@]}" -- "${recipes[@]}"
}
compdef _just_recipes js

function which { # colorized & showing all
	builtin which -a "$@" | bat --language=sh --wrap=character
}

function bat { # dark-mode aware
	local theme   # list themes via `bat --list-themes`
	theme="$(defaults read -g AppleInterfaceStyle &> /dev/null && echo "Dracula" || echo "Monokai Extended Light")"
	command bat --theme="$theme" "$@"
}

#───────────────────────────────────────────────────────────────────────────────

# UTILS
alias sizes_in_cwd="du -sh . ./* | sort -rh | sed 's|\./||'" # size of files in current directory
alias sync_repo='"$(git rev-parse --show-toplevel)/.sync-this-repo.sh"'
alias delete_empty_folders="find . -type d -empty && find . -type d -empty -delete"

export PATH="$HOME/.config/+ utility-scripts/":$PATH
function export_mason_path { export PATH="$HOME/.local/share/nvim/mason/bin":$PATH; }

function cake { mkdir -p "$1" && cd "$1" || return 1; }
function topen { touch "$1" && open "$1"; }
function p { qlmanage -p "$1" &> /dev/null; }

#───────────────────────────────────────────────────────────────────────────────
# GLOBAL ALIAS (to be used at the end of the buffer, mostly)
alias -g G='| rg'
alias -g B='| bat'
alias -g N='| wc -l | tr -d " "' # count lines
alias -g L='| less'
alias -g J='| yq --prettyPrint --output-format=json --colors | less'
alias -g C='| pbcopy ; echo "Copied."'
alias P='pbpaste' # only start of line

# highlights for them
ZSH_HIGHLIGHT_REGEXP+=(' G($| )' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' C$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' B$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' N$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' L$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' J$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=('^P ' 'fg=magenta,bold')

#───────────────────────────────────────────────────────────────────────────────
