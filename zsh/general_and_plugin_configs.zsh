# shellcheck disable=SC2190

#───────────────────────────────────────────────────────────────────────────────
# GENERAL SETTINGS

# sets English everywhere, so that programs behave predictably
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"

# OPTIONS --- (`man zshoptions` to see all options)
setopt AUTO_CD              # pure directory = cd into it
setopt INTERACTIVE_COMMENTS # comments in interactive mode (useful for copypasting)

#───────────────────────────────────────────────────────────────────────────────
# CLI SETTINGS

# you-should-use
export YSU_IGNORED_ALIASES=("bi" "bu") # due to homebrew Alfred workflow
export YSU_MESSAGE_POSITION="after"

# fd
# HACK fixes for `fd` colors when using a light terminal bg https://github.com/sharkdp/fd/issues/1031#issuecomment-1325716744

# fzf
export FZF_DEFAULT_COMMAND='fd --hidden'
export FZF_DEFAULT_OPTS='--color="hl:206" --keep-right --pointer=⟐ --prompt="❱ " --ellipsis=… --scroll-off=3 --cycle --layout=reverse --bind="tab:down,shift-tab:up" --preview-window=border-left --height="90%"'

# rg
export RIPGREP_CONFIG_PATH="$HOME/.config/rg/ripgrep-config"

# magic enter
export MAGIC_ENTER_GIT_COMMAND="inspect"
export MAGIC_ENTER_OTHER_COMMAND="inspect"

# zoxide
export _ZO_DATA_DIR="$DATA_DIR/zoxide/"
eval "$(zoxide init --no-cmd zsh)" # needs to be placed after compinit

# fx
export FX_THEME=1 # only theme working in light & dark mode https://github.com/antonmedv/fx#themes
export FX_SHOW_SIZE=true # show sizes of folded arrays

#───────────────────────────────────────────────────────────────────────────────
# ZSH PLUGIN SETTINGS

# zsh syntax highlighting
export ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets regexp root)

# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/regexp.md
typeset -A ZSH_HIGHLIGHT_REGEXP
# commit msgs too long
ZSH_HIGHLIGHT_REGEXP+=('^(gc -m|acp|git commit -m) "?.{50,}"?' 'fg=white,bold,bg=red')
# dangerous stuff
ZSH_HIGHLIGHT_REGEXP+=('(rm -rf?) .*' 'fg=white,bold,bg=red')
# NOTE: There are also some custom highlights for global aliases int eh aliases.zsh

export ZSH_AUTOSUGGEST_HISTORY_IGNORE="?(#c50,)" # ignores long history items
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
# do not accept autosuggestion when using vim `A`
export ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=("${ZSH_AUTOSUGGEST_ACCEPT_WIDGETS[@]/vi-add-eol/}")

#───────────────────────────────────────────────────────────────────────────────
# GH-CLI
# https://cli.github.com/manual/gh_help_environment
export GH_NO_UPDATE_NOTIFIER=1
export GLAMOUR_STYLE="Dracula"

