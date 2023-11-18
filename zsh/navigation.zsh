# shellcheck disable=2164
# DOCS https://blog.meain.io/2023/navigating-around-in-shell/
#───────────────────────────────────────────────────────────────────────────────

# DOCS https://zsh.sourceforge.io/Doc/Release/Options.html#Changing-Directories
setopt AUTO_CD # pure directory = cd into it
setopt CD_SILENT # don't pwd when changing directories via stack or `-`
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS

export CDPATH="$HOME/.config:$HOME/Repos"

#───────────────────────────────────────────────────────────────────────────────

# INFO leading space to ignore it in history due to HIST_IGNORE_SPACE
alias ..=" cd .."
alias ...=" cd ../.."
alias ....=" cd ../../.."
alias cd="c"

# select recent dir from directory stack
function gr {
	local selected
	selected=$(dirs -pl | 
		sed $'s|/|\e[1;33m/\e[0m|g' |
		fzf --query="$1" --no-sort --ansi \
			--preview-window=right,40% --keep-right \
			--preview="eza {} --no-quotes --color=always --sort=newest --width=\$FZF_PREVIEW_COLUMNS"
	)
	[[ -z "$selected" ]] && return 0
	cd "$selected"
}

#───────────────────────────────────────────────────────────────────────────────

# mkdir and cd
function mkcd {
	mkdir -p "$1" && cd "$1"
}

function c() {
	builtin cd "$@"
	auto_venv
	_magic_dashboard
}

