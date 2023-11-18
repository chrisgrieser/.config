# shellcheck disable=2164
# DOCS https://blog.meain.io/2023/navigating-around-in-shell/
# DOCS https://zsh.sourceforge.io/Doc/Release/Options.html#Changing-Directories
#───────────────────────────────────────────────────────────────────────────────

setopt AUTO_CD     # pure directory = cd into it
setopt CD_SILENT   # don't pwd when changing directories via stack or `-`

setopt CHASE_LINKS # resolve symlinks when changing directories
# `cdpath_bookmarks` contains symlinks to often-visited directories
export CDPATH="$ZDOTDIR/cdpath_bookmarks:$HOME/Repos"

#───────────────────────────────────────────────────────────────────────────────

# INFO leading space to ignore it in history due to HIST_IGNORE_SPACE
alias ..=" cd .."
alias ...=" cd ../.."
alias ....=" cd ../../.."
alias b=" cd -"
alias c=" cd"
alias ..g='cd "$(git rev-parse --show-toplevel)"' # goto git root

#───────────────────────────────────────────────────────────────────────────────

# select recent dir from directory stack
dirs -c # clear dir stack on new shell

setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS

function gr {
	local selected
	selected=$(
		dirs -pl | sed -E $'s|([^/]*)(/)|\e[0;34m\\1\e[0;33m\\2\e[0m|g' |
			fzf --query="$1" --no-sort --ansi --keep-right --exit-0 --select-1 \
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

function chpwd {
	auto_venv
	_magic_dashboard
}

# cd to pwd from last session. Requires setup in `.zlogout`
function ld() {
	last_pwd_location="$ZDOTDIR/.last_pwd"
	if [[ ! -f "$last_pwd_location" ]]; then
		print "\033[1;33mNo Last PWD available.\033[0m"
		return 1
	fi
	last_pwd=$(cat "$last_pwd_location")
	z "$last_pwd"
}
