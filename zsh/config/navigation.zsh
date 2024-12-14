# DOCS
# https://blog.meain.io/2023/navigating-around-in-shell/
# https://zsh.sourceforge.io/Doc/Release/Options.html#Changing-Directories
#───────────────────────────────────────────────────────────────────────────────

# OPTIONS

# make all directories in these folders available as `cd` targets from anywhere
export CDPATH="$HOME/Developer:$HOME/Desktop:$HOME/Vaults"

setopt CD_SILENT # don't echo the directory after `cd`
setopt CHASE_LINKS # follow symlinks when they are `cd` target
# not using `AUTO_CD`, since out tab-mapping is more flexible

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
# RECENT DIRS
# - the list from `dirs` is already populated by zsh-autocomplete, so we do not
#   need to use `AUTO_PUSHD` etc to populate it
# - the zsh builtin `cdr` completes based on a number as argument, so the
#   completions are not searched, which is why we are using this setup of our own

function gr {
	local goto="$*"
	local i=2                  # starting at 2, since 1st line = current
	while [[ -z "$goto" ]]; do # no arg: goto last existing dir
		goto=$(dirs -p | sed -n "${i}p")
		[[ -z "$goto" ]] && return 1 # no more dirs left
		goto="${goto/#\~/$HOME}"
		[[ -d "$goto" ]] && break
		i=$((i++))
	done
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
