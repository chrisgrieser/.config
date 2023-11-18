# shellcheck disable=2164
# DOCS https://blog.meain.io/2023/navigating-around-in-shell/
# DOCS https://zsh.sourceforge.io/Doc/Release/Options.html#Changing-Directories
#───────────────────────────────────────────────────────────────────────────────

# BOOKMARKS (via cdpath & symlinks)
setopt AUTO_CD     # pure directory = cd into it
setopt CD_SILENT   # don't pwd when changing directories via stack or `-`
setopt CHASE_LINKS # resolve symlinks when changing directories

# `cdpath_bookmarks` contains symlinks to often-visited directories
export CDPATH="$ZDOTDIR/cdpath_bookmarks:$HOME/Repos"

function bookmark {
	local marks
	marks=$(echo "$CDPATH" | cut -d':' -f1)
	ln -s "$PWD" "$marks/$1"
}

#───────────────────────────────────────────────────────────────────────────────

# INFO leading space to ignore it in history due to HIST_IGNORE_SPACE
alias ..=" cd .."
alias ...=" cd ../.."
alias ....=" cd ../../.."
alias b=" cd -"
alias ..g='cd "$(git rev-parse --show-toplevel)"' # goto git root

#───────────────────────────────────────────────────────────────────────────────

# RECENT DIRS (via pushd & dirstack)
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
export DIRSTACKSIZE=10

function gr {
	local selected
	selected=$(
		dirs -pl | sed -E $'s|([^/]*)(/)|\e[0;36m\\1\e[0;33m\\2\e[0m|g' |
			fzf --query="$1" --no-sort --ansi \
				--keep-right --with-nth=-2.. --delimiter="/" \
				--preview-window="55%" \
				--preview="printf '\e[7;39m'; echo {} ; echo '\e[0m' ; eza {} --no-quotes --color=always --sort=newest --width=\$FZF_PREVIEW_COLUMNS"
	)
	[[ -z "$selected" ]] && return 0
	cd "$selected"
}

#───────────────────────────────────────────────────────────────────────────────

# mkdir and cd
function mkcd {
	mkdir -p "$1" && cd "$1"
}

# hook when directory is changed (not using chpwd due to interference with scripts)
function cd {
	builtin cd "$1"
	auto_venv
	_magic_dashboard
}
