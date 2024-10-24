# shellcheck disable=SC1091
#───────────────────────────────────────────────────────────────────────────────

# point config paths to `.config`
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"

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
export CLICOLOR=1 # makes `ls` use color by default

export EZA_COLORS="gm=1;38;5;208" # git `modified` with same orange as in starship
export EZA_STRICT=1
export EZA_ICONS_AUTO=1
export EZA_ICON_SPACING=1

export GREP_OPTIONS="--color=auto"
export GREP_COLOR='01;35' # matches in bold & magenta (macOS' `grep` doesn't support `GREP_COLORS`)

#───────────────────────────────────────────────────────────────────────────────

# shellcheck disable=2016
# using `rg` ensures that initially, the list of files is sorted by recently modified files.
export FZF_DEFAULT_COMMAND='rg --no-config --files --sortr=modified --ignore-file="$HOME/.config/ripgrep/ignore"'

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
# NPM
# Don't clutter home directory with useless `.node_repl_history` https://nodejs.org/api/repl.html#repl_environment_variable_options
export NODE_REPL_HISTORY=""

# Instead of writing npm config to `.npmrc`, can also be set via shell
# environment variables. Has to be lower-case though. https://docs.npmjs.com/cli/v10/using-npm/config#environment-variables
export npm_config_fund=false               # disable funding nags
export npm_config_update_notifier=false    # no need for updating prompts, since done via homebrew

# INFO fix for hanging at "sill: idealTree build"
# temporary: export npm_config_strict_ssl=false
# permanent: brew reinstall openssl@3 ca-certificates

#───────────────────────────────────────────────────────────────────────────────

# SEMANTIC PROMPTS (WEZTERM) https://github.com/wez/wezterm/blob/main/assets/shell-integration/wezterm.sh
[[ "$TERM_PROGRAM" == "WezTerm" ]] && source "$ZDOTDIR/plugins/wezterm_semantic_prompts.zsh"

# MAGIC DASHBOARD
source "$ZDOTDIR/plugins/magic_dashboard.zsh"

# STARSHIP
# should be loaded after npm settings
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"
