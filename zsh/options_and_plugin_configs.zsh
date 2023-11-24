# GENERAL SETTINGS

# sets English everywhere, fixes encoding issues
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"

# DOCS https://zsh.sourceforge.io/Doc/Release/Options.html
setopt INTERACTIVE_COMMENTS # comments in interactive mode, useful for copypasting
setopt CORRECT
setopt GLOB_DOTS          # glob includes dotfiles
setopt PIPE_FAIL          # exit if pipeline failed

# nicer command-not-found messages
function command_not_found_handler() {
	print "\e[1;33mCommand not found: \e[1;31m$1\e[0m"
	return 127
}

#───────────────────────────────────────────────────────────────────────────────
# CLI/PLUGIN SETTINGS

# Affects filetype-coloring in eza, fd, and completion menus
# Can generate via: https://github.com/sharkdp/vivid
# DOCS https://github.com/eza-community/eza/blob/main/man/eza_colors.5.md
export LS_COLORS="di=1;34:ln=3;35:or=7;31:ex=39:README.md=4;33"

export YSU_IGNORED_ALIASES=("bi" "pi") # often copypasted without alias
export YSU_MESSAGE_POSITION="after"

export FZF_DEFAULT_COMMAND='fd'
export FZF_DEFAULT_OPTS='
	--color=hl:206,header::reverse --pointer=⟐ --prompt="❱ " --scrollbar=▐ --ellipsis=…  --marker=" +"
	--scroll-off=5 --cycle --layout=reverse --height=90% --preview-window=border-left
	--bind=tab:down,shift-tab:up
	--bind=page-down:preview-page-down,page-up:preview-page-up
	--bind=ctrl-s:toggle+down,ctrl-a:select-all
'

# extra spacing needed for WezTerm + Iosevka
[[ "$TERM_PROGRAM" == "WezTerm" ]] && export EZA_ICON_SPACING=2
export EZA_STRICT=1
export EZA_ICONS_AUTO=1

export RIPGREP_CONFIG_PATH="$HOME/.config/rg/ripgrep-config"

# updates managed via homebrew https://cli.github.com/manual/gh_help_environment
export GH_NO_UPDATE_NOTIFIER=1

#───────────────────────────────────────────────────────────────────────────────
# ZSH PLUGIN SETTINGS

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
