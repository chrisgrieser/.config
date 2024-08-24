# point config paths to `.config`
export RIPGREP_CONFIG_PATH="$HOME/.config/rg/config"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"

# macOS currently ships less v.581, which lacks the ability to read lesskey
# source files. Therefore for this to work, the version of less provided by
# homebrew is needed.
export PAGER="$HOMEBREW_PREFIX/bin/less"
export LESSKEYIN="$HOME/.config/less/lesskey"

#───────────────────────────────────────────────────────────────────────────────

# Affects filetype-coloring in eza, fd, and completion menus
# DOCS https://github.com/eza-community/eza/blob/main/man/eza_colors.5.md
# INFO does also accept specific files via glob, e.g. `README.md=4;33`,
grey="38;5;247"
file_colors=".*=$grey:LICENSE*=$grey:*lock*=$grey" # `.*=` affects dotfiles
export LS_COLORS="di=0;34:ln=3;35:or=7;31:$file_colors"

export EZA_COLORS="gm=1;38;5;208" # git `modified` with same orange as in starship
export EZA_STRICT=1
export EZA_ICONS_AUTO=1
export EZA_ICON_SPACING=1

export GREP_OPTIONS="--color=auto"
export GREP_COLOR='01;35' # matches in bold & magenta (macOS' `grep` doesn't support `GREP_COLORS`)

export CLICOLOR=1 # makes `ls` use color by default

#───────────────────────────────────────────────────────────────────────────────

# shellcheck disable=2016
# using `rg` ensures that initially, the list of files is sorted by recently modified files.
export FZF_DEFAULT_COMMAND='rg --no-config --files --sortr=modified --ignore-file="$HOME/.config/rg/ignore"'

# INFO multi-select `alt-enter` mapping consistent with the one for telescope
export FZF_DEFAULT_OPTS='
	--pointer="" --prompt=" " --scrollbar="▐" --ellipsis="…" --marker=" +"
	--color=hl:208,hl+:208,pointer:206,marker:206
	--scroll-off=5 --cycle --layout=reverse --height=90% --preview-window=border-left
	--bind=tab:down,shift-tab:up
	--bind=page-down:preview-page-down,page-up:preview-page-up
	--bind=alt-enter:toggle+down,ctrl-a:toggle-all
'

# https://cli.github.com/manual/gh_help_environment
export GH_NO_UPDATE_NOTIFIER=1 # updates managed via homebrew

#───────────────────────────────────────────────────────────────────────────────

export ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets regexp)

# DOCS https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/regexp.md
# shellcheck disable=2034 # used in other files
typeset -A ZSH_HIGHLIGHT_REGEXP # actual highlights defined in other files

# DOCS https://github.com/zsh-users/zsh-autosuggestions#configuration
export ZSH_AUTOSUGGEST_HISTORY_IGNORE="?(#c50,)" # ignores long history items
export ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd history completion)
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=30
bindkey '^[' autosuggest-accept # alt+enter

# do not accept autosuggestion when using vim's `A`
export ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=("${ZSH_AUTOSUGGEST_ACCEPT_WIDGETS[@]/vi-add-eol/}")

#───────────────────────────────────────────────────────────────────────────────
# NPM
# Don't clutter home directory with useless `.node_repl_history`
# https://nodejs.org/api/repl.html#repl_environment_variable_options
export NODE_REPL_HISTORY=""

# instead of writing npm config to `.npmrc`, can also be defined as shell
# environment variables. Has to be lower-case though. https://docs.npmjs.com/cli/v10/using-npm/config#environment-variables
export npm_config_fund=false # disable funding nags
export npm_config_update_notifier=false # no need for updating prompts, since done via homebrew
export npm_config_cache="$HOME/.cache/npm" # do not crowd `$HOME`

# FIX for hanging at "sill: idealTree build"
# temporary: export npm_config_strict_ssl=false
# permanent: brew reinstall openssl@3 ca-certificates

#───────────────────────────────────────────────────────────────────────────────
