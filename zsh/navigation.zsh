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
	local bookmark_path
	bookmark_path=$(echo "$CDPATH" | cut -d':' -f1)
	ln -sv "$PWD" "$bookmark_path/$1"
}

function unbookmark {
	local bookmark_path
	bookmark_path=$(echo "$CDPATH" | cut -d':' -f1)
	to_unbookmark=$(find "$bookmark_path" -type l | 
		fzf --with-nth=-1 --delimiter="/" --height=40%
	)
	[[ -z "$to_unbookmark" ]] && return 0
	echo "$to_unbookmark"
}

#───────────────────────────────────────────────────────────────────────────────
# CYCLE THROUGH DIRECTORIES

function _grappling_hook {
	locations=(
		"$WD"
		"$HOME/.config"
		"$VAULT_PATH"
	)
	local to_open
	if [[ "$PWD" == "${locations[1]}" ]]; then
		to_open="${locations[2]}"
	elif [[ "$PWD" == "${locations[2]}" ]]; then
		to_open="${locations[3]}"
	elif [[ "$PWD" == "${locations[3]}" ]]; then
		to_open="${locations[1]}"
	fi
	echo
	cd "$to_open" || return 1
	[[ "$TERM_PROGRAM" == "WezTerm" ]] && wezterm set-working-directory # so wezterm knows we are in a new directory
	zle reset-prompt
}
zle -N _grappling_hook
bindkey "^O" _grappling_hook # bound to cmd+enter via wezterm

#───────────────────────────────────────────────────────────────────────────────

# hook when directory is changed
function chpwd {
	_magic_dashboard
	_auto_venv
}

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
		dirs -pl | sed -E $'s|([^/]*/)|\e[0;38;5;245m\\1\e[0m|g' |
			fzf --query="$1" --no-sort --ansi \
				--keep-right --with-nth=-2.. --delimiter="/" \
				--preview-window="55%" --height="45%" \
				--preview="printf '\e[7;38;5;245m\n{}\n\n\e[0m' ; eza {} --no-quotes --color=always --sort=newest --width=\$FZF_PREVIEW_COLUMNS"
	)
	[[ -d "$selected" ]] && cd "$selected"
}

#───────────────────────────────────────────────────────────────────────────────

# mkdir + cd
function mkcd {
	mkdir -p "$1" && cd "$1"
}
