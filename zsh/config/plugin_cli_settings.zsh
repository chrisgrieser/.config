# point config paths to `.config`
export RIPGREP_CONFIG_PATH="$HOME/.config/rg/ripgrep-config"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"

#───────────────────────────────────────────────────────────────────────────────

# Affects filetype-coloring in eza, fd, and completion menus
# Can generate via: https://github.com/sharkdp/vivid
# DOCS https://github.com/eza-community/eza/blob/main/man/eza_colors.5.md
# INFO does also accept specific files via glob, e.g. `README.md=4;33`,
# `.*=…` affects dotfiles
grey="38;5;247"
file_colors=".*=$grey:LICENSE*=$grey:*lock*=$grey"
export LS_COLORS="di=1;34:ln=3;35:or=7;31:$file_colors"

export EZA_COLORS="gm=1;38;5;208" # `modified` with same orange as in starship
export EZA_STRICT=1
export EZA_ICONS_AUTO=1
[[ "$TERM_PROGRAM" == "WezTerm" ]] && export EZA_ICON_SPACING=2

alias l='eza --all --long --flags --time-style=relative --no-user --smart-group \
	--total-size --no-quotes --git-ignore --sort=newest --hyperlink'

#───────────────────────────────────────────────────────────────────────────────

# INFO multi-select `alt-enter` mapping consistent with the one for telescope
export FZF_DEFAULT_COMMAND='fd'
export FZF_DEFAULT_OPTS='
	--color=hl:206,header::reverse --pointer=⟐ --prompt="❱ " --scrollbar=▐ --ellipsis=… --marker=" +"
	--scroll-off=5 --cycle --layout=reverse --height=90% --preview-window=border-left
	--bind=tab:down,shift-tab:up
	--bind=page-down:preview-page-down,page-up:preview-page-up
	--bind=alt-enter:toggle+down,ctrl-a:toggle-all
'

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
# environment variables. has to be lower-case though.
# https://docs.npmjs.com/cli/v9/using-npm/config#environment-variables
export npm_logs_dir="$HOME/.local/npm/logs" # don't clutter home directory
export npm_cache="$HOME/.cache/npm"
export npm_config_fund=false
export npm_update_notifier=false # updating via homebrew instead

# INFO reinstalling brew package `openssl@3` also seems to fix this
# export npm_config_strict_ssl=false # fix hanging at "sill: idealTree build"

#───────────────────────────────────────────────────────────────────────────────
# LESS
export PAGER="less" # needs to be set explicitly, so the homebrew version is used

# have `less` colorize man pages
export LESS_TERMCAP_mb=$'\E[1;31m' # begin bold
export LESS_TERMCAP_md=$'\E[1;33m' # begin blink
export LESS_TERMCAP_me=$'\E[0m'    # reset bold/blink
export LESS_TERMCAP_us=$'\E[1;36m' # begin underline
export LESS_TERMCAP_ue=$'\E[0m'    # reset underline

export LESS='--RAW-CONTROL-CHARS --line-num-width=3 --chop-long-lines --incsearch --ignore-case --window=-4 --no-init --tilde --long-prompt --quit-if-one-screen'
export LESSHISTFILE=- # don't clutter home directory with useless `.lesshst` file

# INFO Keybindings
# - macOS currently ships less v.581, which lacks the ability to read lesskey
#   source files. Therefore for this to work, the version of less provided by
#   homebrew is needed (v.633)
# - keybinding for search includes a setting that makes `n` and `N` wrap
export LESSKEYIN="$ZDOTDIR/lesskey"

# FIX display nerdfont correctly https://github.com/ryanoasis/nerd-fonts/issues/1337
export LESSUTFCHARDEF=23fb-23fe:p,2665:p,26a1:p,2b58:p,e000-e00a:p,e0a0-e0a2:p,e0a3:p,e0b0-e0b3:p,e0b4-e0c8:p,e0ca:p,e0cc-e0d4:p,e200-e2a9:p,e300-e3e3:p,e5fa-e6a6:p,e700-e7c5:p,ea60-ebeb:p,f000-f2e0:p,f300-f32f:p,f400-f532:p,f500-fd46:p,f0001-f1af0:p
