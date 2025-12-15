# DOCS
# https://blog.meain.io/2023/navigating-around-in-shell/
# https://zsh.sourceforge.io/Doc/Release/Options.html#Changing-Directories

#-OPTIONS-----------------------------------------------------------------------

# make all directories in these folders available as `cd` targets from anywhere
export CDPATH="$HOME/Desktop/:$HOME/Developer/:$ZDOTDIR/cd-bookmarks"

setopt CD_SILENT   # don't echo the directory after `cd`
setopt CHASE_LINKS # follow symlinks when they are `cd` target (for symlinks in `cd-bookmarks`)
setopt AUTO_CD     # `cd` to directories without typing `cd`

# post-directory-change-hook (use `cd -q` to suppress this hook)
function chpwd {
	_magic_dashboard
	_auto_venv
}

#-SHORTHANDS--------------------------------------------------------------------
alias ..=" builtin cd .." # leading space to ignore it in history due to `HIST_IGNORE_SPACE`
alias ...=" builtin cd ../.."
alias ....=" builtin cd ../../.."
alias .....=" builtin cd ../../../.."
function -() { builtin cd - || return; } # `-` to trigger `cd -` (workaround since cannot set alias for `-`)

#-RECENT DIRS-------------------------------------------------------------------
# my own implementation of `chpwd_recent_dirs` using zsh's directory stack for
# completing full file paths and more control over filtering since excluding
# files with `recent-dirs-prune` does not work for me.
# The directory stack is saved by `zsh-autocomplete`, see also https://github.com/marlonrichert/zsh-autocomplete/issues/837

function gr {
	local goto=${1:-"$OLDPWD"}
	cd "$goto" || return 1
}

_gr() {
	local -a folders=() # turn lines from `dirs -p` into array for `compadd`
	while IFS='' read -r dir; do
		local abspath="${dir/#\~/$HOME}"
		[[ -d "$abspath" && "$abspath" != "$PWD" && "$abspath" != "$HOME" ]] && folders+=("$dir")
	done < <(dirs -p) # remove current directory

	local expl && _description -V recent-folders expl 'Recent folders'
	compadd "${expl[@]}" -Q -- "${folders[@]}"
}
compdef _gr gr

#-KEYMAPS-----------------------------------------------------------------------

# cmd+enter -> goto desktop / dotfiles
function _grappling_hook {
	local target="$HOME/Desktop"
	[[ "$PWD" == "$target" ]] && target="$HOME/.config"
	builtin cd -q "$target" || return 1
	zle reset-prompt
	if [[ "$TERM_PROGRAM" == "WezTerm" ]]; then wezterm set-working-directory; fi
}
zle -N _grappling_hook
bindkey '^O' _grappling_hook # remapped to `cmd+enter` via karabiner

# cmd+l -> reveal cwd in finder
function _reaveal_cwd_in_Finder { open .; }
zle -N _reaveal_cwd_in_Finder
bindkey '^L' _reaveal_cwd_in_Finder # remapped to `cmd+l` via karabiner
