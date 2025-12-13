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
# https://zsh.sourceforge.io/Doc/Release/User-Contributions.html#Recent-Directories
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
alias gr=" cdr"

zstyle ':chpwd:*' recent-dirs-max 20
zstyle ':chpwd:*' recent-dirs-file "$HOME/.local/share/zsh/chpwd-recent-dirs"

# together, these make `cdr` search for and insert the instead of numbers
zstyle ':chpwd:*' recent-dirs-default true # make `cdr` fallback to `cd`
zstyle ':completion:*' recent-dirs-insert "always" # insert dir instead of numbers
zstyle ':chpwd:*:*' recent-dirs-prune "parent" # using "pattern:…" not working

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
