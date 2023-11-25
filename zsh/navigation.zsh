# DOCS https://blog.meain.io/2023/navigating-around-in-shell/
# DOCS https://zsh.sourceforge.io/Doc/Release/Options.html#Changing-Directories
#───────────────────────────────────────────────────────────────────────────────

# POST-DIRECTORY-CHANGE-HOOK 
# (use `cd -q` to suppress this hook)
function chpwd {
	_magic_dashboard
	_auto_venv
}

#───────────────────────────────────────────────────────────────────────────────
# SHORTHANDS

# INFO leading space to ignore it in history due to HIST_IGNORE_SPACE
alias ..=" cd .."
alias ...=" cd ../.."
alias ....=" cd ../../.."
alias ..g=' cd "$(git rev-parse --show-toplevel)"' # goto git root
# shellcheck disable=2164
function mkcd { mkdir -p "$1" && cd "$1"; } # mkdir + cd

#───────────────────────────────────────────────────────────────────────────────
# RECENT DIRS
# DOCS https://zsh.sourceforge.io/Doc/Release/User-Contributions.html#Recent-Directories
# INFO cannot use `zstyle ':chpwd:*' recent-dirs-prune`, since zsh-autocomplete
# overrides it

autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
alias gr=" cdr"

#───────────────────────────────────────────────────────────────────────────────

# BOOKMARKS (via cdpath & symlinks)
setopt AUTO_CD     # pure directory = cd into it
setopt CHASE_LINKS # resolve symlinks when changing directories

bookmark_path="$ZDOTDIR/cdpath_bookmarks" # folder with symlinks to directories
export CDPATH="$bookmark_path:$LOCAL_REPOS:$WD"

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
	zle reset-prompt

	# so wezterm knows we are in a new directory
	[[ "$TERM_PROGRAM" == "WezTerm" ]] && wezterm set-working-directory
}
zle -N _grappling_hook
bindkey "^O" _grappling_hook # bound to cmd+enter via wezterm
