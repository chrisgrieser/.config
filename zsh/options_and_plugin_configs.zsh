# shellcheck disable=SC2190

#───────────────────────────────────────────────────────────────────────────────
# GENERAL SETTINGS

# sets English everywhere, so that programs behave predictably
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8" # fixes encoding issue when copying

# OPTIONS -- https://zsh.sourceforge.io/Doc/Release/Options.html
setopt AUTO_CD              # pure directory = cd into it

# comments in interactive mode (useful for copypasting)
setopt INTERACTIVE_COMMENTS

#───────────────────────────────────────────────────────────────────────────────
# CLI SETTINGS

export YSU_IGNORED_ALIASES=("bi" "pi") # often copypasted without alias
export YSU_MESSAGE_POSITION="after"

export FZF_DEFAULT_COMMAND='fd --hidden'
export FZF_DEFAULT_OPTS='
	--color=hl:206 --pointer=⟐ --prompt="❱ " --scrollbar=▐ --ellipsis=… 
	--scroll-off=5 --cycle --layout=reverse --height=90%
	--bind=tab:down,shift-tab:up,shift-down:preview-page-down,shift-up:preview-page-up
	--preview-window=border-left
'

# extra spacing needed for WezTerm + Iosevka
if [[ "$TERM_PROGRAM" == "WezTerm" ]]; then 
	export EZA_ICON_SPACING=2
	export EXA_ICON_SPACING=2
fi
export EZA_STRICT=1
export EXA_STRICT=1

export RIPGREP_CONFIG_PATH="$HOME/.config/rg/ripgrep-config"

# leading space to ignore it in history due to HIST_IGNORE_SPACE
export MAGIC_ENTER_GIT_COMMAND=" inspect" 
export MAGIC_ENTER_OTHER_COMMAND=" inspect"

# zoxide
export _ZO_DATA_DIR="$DATA_DIR/zoxide/"
eval "$(zoxide init --no-cmd zsh)" # needs to be placed after compinit

# updates managed via homebrew https://cli.github.com/manual/gh_help_environment
export GH_NO_UPDATE_NOTIFIER=1

#───────────────────────────────────────────────────────────────────────────────
# ZSH PLUGIN SETTINGS

export ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets regexp root)

# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/regexp.md
typeset -A ZSH_HIGHLIGHT_REGEXP
# commit messages longer than 50 chars: yellow, longer than 72 chars: red
ZSH_HIGHLIGHT_REGEXP+=('^(acp?|gc -m|git commit -m) ".{72,}"' 'fg=white,bold,bg=red')
ZSH_HIGHLIGHT_REGEXP+=('^(acp?|gc -m|git commit -m) ".{51,71}"' 'fg=white,bold,bg=yellow') 

# NOTE: There are also some custom highlights for global aliases in aliases.zsh

export ZSH_AUTOSUGGEST_HISTORY_IGNORE="?(#c50,)" # ignores long history items
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
# do not accept autosuggestion when using vim `A`
export ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=("${ZSH_AUTOSUGGEST_ACCEPT_WIDGETS[@]/vi-add-eol/}")
