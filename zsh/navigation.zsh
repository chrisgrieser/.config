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
alias b=" cd -"
alias c=" cd"

# select recent dir from directory stack
function gr {
	local selected
	selected=$(dirs -pl | sed -E $'s|([^/]*)(/)|\e[0;34m\\1\e[0;33m\\2\e[0m|g' |
		fzf --query="$1" --no-sort --ansi --keep-right \
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

function cd() {
	builtin cd "$@"
	auto_venv
	_magic_dashboard
}

