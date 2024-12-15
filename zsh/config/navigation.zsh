# DOCS
# https://blog.meain.io/2023/navigating-around-in-shell/
# https://zsh.sourceforge.io/Doc/Release/Options.html#Changing-Directories
#───────────────────────────────────────────────────────────────────────────────

# OPTIONS

# make all directories in these folders available as `cd` targets from anywhere
export CDPATH="$HOME/Desktop/:$HOME/Developer/:$HOME/Vaults"

setopt CD_SILENT   # don't echo the directory after `cd`
setopt CHASE_LINKS # follow symlinks when they are `cd` target
setopt AUTO_CD     # `cd` to directories without typing `cd`
setopt AUTO_PUSHD  # push to directory stack on cd (used for own `gr` function)

# POST-DIRECTORY-CHANGE-HOOK (use `cd -q` to suppress this hook)
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

#───────────────────────────────────────────────────────────────────────────────

# cmd+enter -> goto desktop
function _goto_desktop {
	cd "$HOME/Desktop" || return 1
	zle reset-prompt
	[[ "$TERM_PROGRAM" == "WezTerm" ]] && wezterm set-working-directory
}
zle -N _goto_desktop
bindkey '^O' _goto_desktop # remapped to cmd+enter in wezterm keybindings

#───────────────────────────────────────────────────────────────────────────────
# RECENT DIRS
# the zsh builtin `cdr` does something similar, but completes based on a number
# as argument, so the completions are not searched

function gr {
	local goto=${1:-"$OLDPWD"}
	cd "$goto" || return 1
}

_gr() {
	[[ $CURRENT -ne 2 ]] && return # only complete first word

	# get existing dirs
	local -a folders=()
	while IFS='' read -r dir; do # turn lines into array
		expanded_dir="${dir/#\~/$HOME}"
		[[ -d "$expanded_dir" ]] && folders+=("$dir")
	done < <(dirs -p | sed '1d')

	local expl && _description -V recent-folders expl 'Recent Folders'
	compadd "${expl[@]}" -Q -- "${folders[@]}"
}
compdef _gr gr

#───────────────────────────────────────────────────────────────────────────────
