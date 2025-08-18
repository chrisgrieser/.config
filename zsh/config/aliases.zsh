# SHORTHANDS
alias q=' exit'     # leading space to ignore it in history due to `HIST_IGNORE_SPACE`
alias r=' exec zsh' # do not reload with `source ~/.zshrc`, https://github.com/ohmyzsh/ohmyzsh/wiki/FAQ#how-do-i-reload-the-zshrc-file
alias ydl='yt-dlp' # cause I can never remember the name
alias i='which' # i for [i]nspect

# DEFAULTS
alias mv='mv -vi'
alias ln='ln -vwis'
alias cp='cp -vi'
alias rm='rm -I'
alias vidir='vidir --verbose'
alias curl='curl --progress-bar'
alias zip='zip --recurse-paths --symlinks'

#───────────────────────────────────────────────────────────────────────────────

# EZA
alias ls='eza --all --sort=newest --hyperlink --no-quotes --ignore-glob=".DS_Store" \
	--time-style=relative --no-user'

# JUST
alias j='just'
alias ji='just init'
alias jr='just release'

#───────────────────────────────────────────────────────────────────────────────

function which { # colorized & showing all
	builtin which -a "$@" | bat --language=sh --wrap=character
}

function bat { # dark-mode aware
	local theme   # list themes via `bat --list-themes`
	theme="$(defaults read -g AppleInterfaceStyle &> /dev/null && echo "Dracula" || echo "Monokai Extended Light")"
	command bat --theme="$theme" "$@"
}

#───────────────────────────────────────────────────────────────────────────────

# 1. Define `pass cd` as pseudo-subcommand to go to the password store directory.
# 2. Set `USING_PASS`, so nvim can detect `pass` and disable plugins.
function pass {
	if [[ "$1" == "cd" ]]; then
		cd "$PASSWORD_STORE_DIR" || return 1
	else
		env "USING_PASS=true" command pass "$@"
	fi
}
alias pw="pass"

#───────────────────────────────────────────────────────────────────────────────
# GLOBAL ALIASES
alias -g G='| rg'
alias -g B='| bat'
alias -g N='| wc -l | tr -d " "' # count lines
alias -g L='| less'
alias -g J='| jq --color-output | less'
alias -g C='| pbcopy ; echo "Copied."'
alias P='pbpaste'

# highlights for them
ZSH_HIGHLIGHT_REGEXP+=(' G$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' C$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' B$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' N$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' L$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' J$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=('^P ' 'fg=magenta,bold') # only start of line
