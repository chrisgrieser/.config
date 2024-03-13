# DOCS https://blog.meain.io/2023/navigating-around-in-shell/
# DOCS https://zsh.sourceforge.io/Doc/Release/Options.html#Changing-Directories
#───────────────────────────────────────────────────────────────────────────────
# OPTIONS

setopt AUTO_CD # pure directory = cd into it
setopt CD_SILENT
setopt CHASE_LINKS # follow symlinks when they are cd target
export CDPATH="$LOCAL_REPOS:$WD"

# POST-DIRECTORY-CHANGE-HOOK
# (use `cd -q` to suppress this hook)
function chpwd {
	_magic_dashboard
	_auto_venv
}

#───────────────────────────────────────────────────────────────────────────────
# SHORTHANDS

# INFO leading space to ignore it in history due to HIST_IGNORE_SPACE
alias -=" cd -"
alias ..=" cd .."
alias ...=" cd ../.."
alias ....=" cd ../../.."
alias ..g=' cd "$(git rev-parse --show-toplevel)"' # goto git root

#───────────────────────────────────────────────────────────────────────────────
# RECENT DIRS
# DOCS https://zsh.sourceforge.io/Doc/Release/User-Contributions.html#Recent-Directories
# autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
# add-zsh-hook chpwd chpwd_recent_dirs
# alias gr=" cdr"

function gr {
	cd "$@" || return 1
}

_gr() {
	local -a folders=()
	while IFS='' read -r dir; do folders+=("$dir"); done < <(dirs -p) # turn lines into array
	local expl && _description -V recent-folders expl 'Recent Folders'
	compadd "${expl[@]}" -- "${folders[@]}"
}
compdef _gr gr

#───────────────────────────────────────────────────────────────────────────────
# CYCLE THROUGH DIRECTORIES

function _grappling_hook {
	locations=(
		"$WD"
		"$HOME/.config"
		"$VAULT_PATH"
		"$PHD_DATA_VAULT"
	)
	local to_open="${locations[1]}"
	local locations_count=${#locations[@]}
	for ((i=1; i <= locations_count - 1; i++)); do
		[[ "$PWD" == "${locations[$i]}" ]] && to_open="${locations[$((i + 1))]}"
	done
	cd -q "$to_open" || return 1
	zle reset-prompt

	# so wezterm knows we are in a new directory
	[[ "$TERM_PROGRAM" == "WezTerm" ]] && wezterm set-working-directory
}
zle -N _grappling_hook
bindkey "^O" _grappling_hook # bound to cmd+enter via wezterm
