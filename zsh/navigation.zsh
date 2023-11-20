# shellcheck disable=2164
# DOCS https://blog.meain.io/2023/navigating-around-in-shell/
# DOCS https://zsh.sourceforge.io/Doc/Release/Options.html#Changing-Directories
#───────────────────────────────────────────────────────────────────────────────

# GENERAL
setopt AUTO_CD   # pure directory = cd into it
setopt CD_SILENT # don't pwd when changing directories via stack or `-`

# hook when directory is changed (use `cd -q` to suppress hook)
function chpwd {
	_magic_dashboard
	_auto_venv
}

#───────────────────────────────────────────────────────────────────────────────
# SHORTHANDS

# INFO leading space to ignore it in history due to HIST_IGNORE_SPACE
alias b=" cd ~+1" # dir back (requires AUTO_PUSHD; `cd -` doesn't work at session start)
alias ..=" cd .."
alias ...=" cd ../.."
alias ....=" cd ../../.."
alias ..g=' cd "$(git rev-parse --show-toplevel)"' # goto git root
function mkcd { mkdir -p "$1" && cd "$1"; }        # mkdir + cd

#───────────────────────────────────────────────────────────────────────────────

# BOOKMARKS (via cdpath & symlinks)
setopt CHASE_LINKS # resolve symlinks when changing directories

bookmark_path="$ZDOTDIR/cdpath_bookmarks" # folder with symlinks to directories
export CDPATH="$bookmark_path:$LOCAL_REPOS:$WD"

function bookmark {
	ln -s "$PWD" "$bookmark_path/$1" && echo "Bookmarked: $(basename "$PWD")"
}

function unbookmark {
	if [[ ! -x "$(command -v fzf)" ]]; then print "\e[1;33mfzf not installed.\e[0m" && return 1; fi
	to_unbookmark=$(find "$bookmark_path" -type l | fzf --with-nth=-1 --delimiter="/")
	[[ -z "$to_unbookmark" ]] && return 0 # aborted
	rm "$to_unbookmark" && echo "Removed Bookmark: $(basename "$to_unbookmark")"
}

#───────────────────────────────────────────────────────────────────────────────
# CYCLE THROUGH DIRECTORIES

function _grappling_hook {
	locations=(
		"$WD"
		"$HOME/.config"
		"$VAULT_PATH"
	)
	local to_open="${locations[1]}"
	if [[ "$PWD" == "${locations[1]}" ]]; then
		to_open="${locations[2]}"
	elif [[ "$PWD" == "${locations[2]}" ]]; then
		to_open="${locations[3]}"
	fi
	cd -q "$to_open" || return 1
	[[ "$TERM_PROGRAM" == "WezTerm" ]] && wezterm set-working-directory # so wezterm knows we are in a new directory
	zle reset-prompt
}
zle -N _grappling_hook
bindkey "^O" _grappling_hook # bound to cmd+enter via wezterm

#───────────────────────────────────────────────────────────────────────────────
# RECENT DIRS (via pushd & dirstack)

setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
export DIRSTACKSIZE=13

function gr {
	if [[ ! -x "$(command -v fzf)" ]]; then print "\e[1;33mfzf not installed.\e[0m" && return 1; fi

	local selected
	selected=$(
		dirs -pl | sed -e '1d' -Ee $'s|([^/]*/)|\e[0;38;5;245m\\1\e[0m|g' |
			fzf --query="$1" --no-sort --ansi \
				--keep-right --with-nth=-2.. --delimiter="/" \
				--preview-window="55%" --height="45%" \
				--preview="printf '\e[7;38;5;245m\n{}\n\n\e[0m' ; eza {} --no-quotes --color=always --sort=newest --width=\$FZF_PREVIEW_COLUMNS"
	)
	[[ -z "$selected" ]] && return 0
	cd "$selected"
}

#───────────────────────────────────────────────────────────────────────────────
