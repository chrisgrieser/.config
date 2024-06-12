# DOCS
# https://blog.meain.io/2023/navigating-around-in-shell/
# https://zsh.sourceforge.io/Doc/Release/Options.html#Changing-Directories
#───────────────────────────────────────────────────────────────────────────────

# CONFIG
wd="$HOME/Desktop"
local_repos="$HOME/repos"

#───────────────────────────────────────────────────────────────────────────────

# OPTIONS
setopt AUTO_CD # pure directory = cd into it
setopt CD_SILENT
setopt CHASE_LINKS # follow symlinks when they are cd target
export CDPATH="$local_repos:$wd"

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

#───────────────────────────────────────────────────────────────────────────────
# GOTO active location of various apps (all mac-only)

# FINDER window
function ..f {
	finder_dir=$(osascript -e 'tell application "Finder" to return POSIX path of (insertion location as alias)' 2> /dev/null)
	if [[ ! -d "$finder_dir" ]]; then
		print "\e[1;33mNo Finder window found.\e[0m"
		return 1
	fi
	cd "$finder_dir" || return 1
}

# NVIM cwd
function ..n {
	if ! pgrep -qx "neovide"; then
		print "\e[1;33mNeovide not running.\e[0m"
		return 1
	fi
	# INFO requires `vim.opt.titlestring = "%{getcwd()}"` in nvim config
	nvim_cwd=$(osascript -e 'tell application "System Events" to tell process "neovide" to return name of front window')
	cd "$nvim_cwd" || return 1
}

# ALFRED workflow
function ..a {
	# https://www.alfredforum.com/topic/18390-get-currently-edited-workflow-uri/
	workflow_id=$(sed -n "4p" "$HOME/Library/Application Support/Alfred/history.json" | cut -d'"' -f2)
	prefs_location=$(grep "current" "$HOME/Library/Application Support/Alfred/prefs.json" | cut -d'"' -f4 | sed -e 's|\\/|/|g' -e "s|^~|$HOME|")
	workflow_folder_path="$prefs_location/workflows/$workflow_id"
	cd "$workflow_folder_path" || return 1
}

# open first ejectable volume
function vol {
	first_volume=$(df | grep --max-count=1 " /Volumes/" | awk -F '   ' '{print $NF}')
	if [[ -d "$first_volume" ]]; then
		open "$first_volume"
	else
		print "\e[1;33mEjectable volumes found.\e[0m"
	fi
}

#───────────────────────────────────────────────────────────────────────────────
# RECENT DIRS
# - the list from `dirs` is already populated by zsh-autocomplete, so we do not
#   need to use `AUTO_PUSHD` etc to populate it
# - the zsh builtin `cdr` completes based on a number as argument, so the
#   completions are not searched, which is why we are using this setup of our own

function gr {
	local goto="$*"
	[[ -z "$*" ]] && goto=$(dirs -p | sed -n '2p') # no arg: goto last (1st line = current)
	goto="${goto/#\~/$HOME}"
	cd "$goto" || return 1
}
_gr() {
	[[ $CURRENT -ne 2 ]] && return # only complete first word

	# get existing dirs
	local -a folders=()
	while IFS='' read -r dir; do # turn lines into array
		expanded_dir="${dir/#\~/$HOME}"
		[[ -d "$expanded_dir" ]] && folders+=("\"$dir\"")
	done < <(dirs -p | sed '1d')

	local expl && _description -V recent-folders expl 'Recent Folders'
	compadd "${expl[@]}" -Q -- "${folders[@]}"
}
compdef _gr gr

#───────────────────────────────────────────────────────────────────────────────
# CYCLE THROUGH DIRECTORIES

function _grappling_hook {
	# CONFIG one location per line
	# 1. read from csv, 2. remove .password-store, 3. add Desktop
	local locations
	locations=$(cut -d, -f2 "$HOME/.config/perma-repos.csv" | sed "s|^~|$HOME|")
	locations="$wd"$'\n'"$(echo "$locations" | grep -v ".password-store")"

	local to_open locations_count dir
	to_open=$(echo "$locations" | sed -n "1p")
	locations_count=$(echo "$locations" | wc -l)

	for ((i = 1; i <= locations_count - 1; i++)); do
		dir=$(echo "$locations" | sed -n "${i}p")
		[[ "$PWD" == "$dir" ]] && to_open=$(echo "$locations" | sed -n "$((i + 1))p")
	done
	cd -q "$to_open" || return 1
	zle reset-prompt

	# so wezterm knows we are in a new directory
	[[ "$TERM_PROGRAM" == "WezTerm" ]] && wezterm set-working-directory
}
zle -N _grappling_hook
bindkey "^O" _grappling_hook # bound to cmd+enter via wezterm
