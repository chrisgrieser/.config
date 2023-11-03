# GENERAL SETTINGS

# sets English everywhere, so that programs behave predictably
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8" # fixes encoding issue when copying

# OPTIONS -- https://zsh.sourceforge.io/Doc/Release/Options.html
setopt AUTO_CD              # pure directory = cd into it

# comments in interactive mode (useful for copypasting)
setopt INTERACTIVE_COMMENTS

# when a pipe fails, whole command fails
set -o pipefail

#───────────────────────────────────────────────────────────────────────────────
# CLI/PLUGIN SETTINGS

export YSU_IGNORED_ALIASES=("bi" "pi") # often copypasted without alias
export YSU_MESSAGE_POSITION="after"

export FZF_DEFAULT_COMMAND='fd --hidden'
export FZF_DEFAULT_OPTS='
	--color=hl:206,header::reverse --pointer=⟐ --prompt="❱ " --scrollbar=▐ --ellipsis=…  --marker=" +"
	--scroll-off=5 --cycle --layout=reverse --height=90% --preview-window=border-left
	--bind=tab:down,shift-tab:up
	--bind=page-down:preview-page-down,page-up:preview-page-up
	--bind=ctrl-s:select+down,ctrl-a:select-all
'

# extra spacing needed for WezTerm + Iosevka
[[ "$TERM_PROGRAM" == "WezTerm" ]] && export EZA_ICON_SPACING=2
export EZA_STRICT=1

export RIPGREP_CONFIG_PATH="$HOME/.config/rg/ripgrep-config"

# zoxide
export _ZO_DATA_DIR="$DATA_DIR/zoxide/"
eval "$(zoxide init --no-cmd zsh)" # needs to be placed after compinit
export _ZO_FZF_OPTS="
	$FZF_DEFAULT_OPTS --height=50% --with-nth=2.. --preview-window=right
	--preview='eza {2} --icons --color=always --width=\$FZF_PREVIEW_COLUMNS'
"

# updates managed via homebrew https://cli.github.com/manual/gh_help_environment
export GH_NO_UPDATE_NOTIFIER=1

#───────────────────────────────────────────────────────────────────────────────
# ZSH PLUGIN SETTINGS

export ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets regexp root)

# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/regexp.md
# shellcheck disable=2034 # used in other files
typeset -A ZSH_HIGHLIGHT_REGEXP
# NOTE: There are also some custom highlights for global aliases in aliases.zsh

export ZSH_AUTOSUGGEST_HISTORY_IGNORE="?(#c50,)" # ignores long history items
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
# do not accept autosuggestion when using vim `A`
export ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=("${ZSH_AUTOSUGGEST_ACCEPT_WIDGETS[@]/vi-add-eol/}")
