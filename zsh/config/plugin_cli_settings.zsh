# Affects filetype-coloring in eza, fd, and completion menus
# Can generate via: https://github.com/sharkdp/vivid
# DOCS https://github.com/eza-community/eza/blob/main/man/eza_colors.5.md
# INFO does also accept specific files via glob, e.g. `README.md=4;33`, 
# `.*=…` affects dotfiles
export LS_COLORS="di=1;34:ln=3;35:or=7;31:ex=39:.*=38;5;247"

export EZA_COLORS="gm=1;38;5;208" # `modified` with same orange as in starship
export EZA_STRICT=1
export EZA_ICONS_AUTO=1
[[ "$TERM_PROGRAM" == "WezTerm" ]] && export EZA_ICON_SPACING=2

#───────────────────────────────────────────────────────────────────────────────

export FZF_DEFAULT_COMMAND='fd'
export FZF_DEFAULT_OPTS='
	--color=hl:206,header::reverse --pointer=⟐ --prompt="❱ " --scrollbar=▐ --ellipsis=…  --marker=" +"
	--scroll-off=5 --cycle --layout=reverse --height=90% --preview-window=border-left
	--bind=tab:down,shift-tab:up
	--bind=page-down:preview-page-down,page-up:preview-page-up
	--bind=ctrl-s:toggle+down,ctrl-a:toggle-all
'


export RIPGREP_CONFIG_PATH="$HOME/.config/rg/ripgrep-config"

# updates managed via homebrew https://cli.github.com/manual/gh_help_environment
export GH_NO_UPDATE_NOTIFIER=1

export ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets regexp)

# DOCS https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/regexp.md
# shellcheck disable=2034 # used in other files
typeset -A ZSH_HIGHLIGHT_REGEXP # actual highlights defined in other files

# DOCS https://github.com/zsh-users/zsh-autosuggestions#configuration
export ZSH_AUTOSUGGEST_HISTORY_IGNORE="?(#c50,)" # ignores long history items
export ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd history completion)
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=30

# do not accept autosuggestion when using vim `A`
export ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=("${ZSH_AUTOSUGGEST_ACCEPT_WIDGETS[@]/vi-add-eol/}")

#───────────────────────────────────────────────────────────────────────────────
# NPM
# Don't clutter home directory with useless `.node_repl_history`
# https://nodejs.org/api/repl.html#repl_environment_variable_options
export NODE_REPL_HISTORY=""

# INFO instead of writing npm config to ~/.npmrc, they can also be defined as shell
# environment variables https://docs.npmjs.com/cli/v9/using-npm/config#environment-variables

export npm_config_fund=false # disable funding reminder, has to be lowercase
