# shellcheck disable=2164
# DOCS https://blog.meain.io/2023/navigating-around-in-shell/
# DOCS https://zsh.sourceforge.io/Doc/Release/Options.html#Changing-Directories
#───────────────────────────────────────────────────────────────────────────────

# BOOKMARKS (via cdpath & symlinks)
setopt AUTO_CD     # pure directory = cd into it
setopt CD_SILENT   # don't pwd when changing directories via stack or `-`
setopt CHASE_LINKS # resolve symlinks when changing directories

bookmark_path="$ZDOTDIR/cdpath_bookmarks" # folder with symlinks to directories
export CDPATH="$bookmark_path:$LOCAL_REPOS"

function bookmark {
	ln -sv "$PWD" "$bookmark_path/$1"
}

function unbookmark {
	to_unbookmark=$(find "$bookmark_path" -type l | fzf --with-nth=-1 --delimiter="/")
	[[ -n "$to_unbookmark" ]] && return 0 # aborted
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
	cd "$to_open" || return 1
	[[ "$TERM_PROGRAM" == "WezTerm" ]] && wezterm set-working-directory # so wezterm knows we are in a new directory
	zle reset-prompt
}
zle -N _grappling_hook
bindkey "^O" _grappling_hook # bound to cmd+enter via wezterm

#───────────────────────────────────────────────────────────────────────────────

# INFO leading space to ignore it in history due to HIST_IGNORE_SPACE
alias b=" cd -"
alias ..=" cd .."
alias ...=" cd ../.."
alias ....=" cd ../../.."
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
