# shellcheck disable=SC1091
#───────────────────────────────────────────────────────────────────────────────

# Affects filetype-coloring in eza, fd, and completion menus
# DOCS https://github.com/eza-community/eza/blob/main/man/eza_colors.5.md
# INFO does also accept specific files via glob, e.g. `README.md=4;33`,
grey="38;5;247"
file_colors=".*=$grey:LICENSE*=$grey:*lock*=$grey" # `.*=` affects dotfiles
export LS_COLORS="di=0;34:ln=3;35:or=7;31:$file_colors"
export CLICOLOR=1 # makes `ls` use color by default

# gm = git `modified` with same orange as in starship
# lp = path of symlink or path when using `--stdin`
export EZA_COLORS="gm=1;38;5;208:lp=0;34"

export EZA_STRICT=1
export EZA_ICONS_AUTO=1
export EZA_ICON_SPACING=1

#───────────────────────────────────────────────────────────────────────────────

export GREP_OPTIONS="--color=auto"
export GREP_COLOR='01;35' # matches in bold & magenta (macOS' `grep` doesn't support `GREP_COLORS`)

export JUST_COMMAND_COLOR="blue"

#───────────────────────────────────────────────────────────────────────────────

LESS+=" --RAW-CONTROL-CHARS" # process colors correctly
LESS+=" --line-num-width=4" # line number column width
LESS+=" --ignore-case --incsearch"
LESS+=" --tilde" # no tilde at start of line at the end of file
LESS+=" --long-prompt --prompt=mpage %dm?B/%D.?Pm (%Pm\\%).$" # progress in pages
LESS+=" --status-line" # highlight lines with a mark
LESS+=" --quit-if-one-screen --no-init" # quicker leaving & do not clear the screen when doing so
LESS+=" --chop-long-lines" # wrap lines
LESS+=" --shift=.2" # amount of side-scrolling (percentage of screen width)
export LESS

#───────────────────────────────────────────────────────────────────────────────

export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config" # point config paths to `.config`

# INFO multi-select `alt-enter` mapping consistent with the one for telescope
export FZF_DEFAULT_OPTS='
	--pointer="" --prompt=" " --scrollbar="▐" --ellipsis="…" --marker=" "
	--color=hl:208,hl+:208,pointer:206,marker:206
	--scroll-off=5 --cycle --layout=reverse --height=90% --preview-window=border-left
	--bind=tab:down,shift-tab:up
	--bind=page-down:preview-page-down,page-up:preview-page-up
	--bind=alt-enter:toggle+down,ctrl-a:toggle-all
'

# https://cli.github.com/manual/gh_help_environment
export GH_NO_UPDATE_NOTIFIER=1 # updates managed via homebrew

#───────────────────────────────────────────────────────────────────────────────
# NPM & NODE

# Don't clutter home directory with useless `.node_repl_history` https://nodejs.org/api/repl.html#repl_environment_variable_options
export NODE_REPL_HISTORY=""

# Instead of writing npm config to `.npmrc`, can also be set via shell
# environment variables. Has to be lower-case then. https://docs.npmjs.com/cli/v10/using-npm/config#environment-variables
export npm_config_fund=false               # disable funding nags
export npm_config_update_notifier=false    # no need for updating prompts, since done via homebrew

# do not crowd `$HOME`
export npm_config_cache="$HOME/.cache/npm"

#───────────────────────────────────────────────────────────────────────────────
