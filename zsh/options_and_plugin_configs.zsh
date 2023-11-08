# GENERAL SETTINGS

# sets English everywhere, fixes encoding issues
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"

# DOCS https://zsh.sourceforge.io/Doc/Release/Options.html
setopt AUTO_CD # pure directory = cd into it
setopt INTERACTIVE_COMMENTS # comments in interactive mode (useful for copypasting)

# MATCHING / COMPLETION
# case insensitive path-completion - https://scriptingosx.com/2019/07/moving-to-zsh-part-5-completions/
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 

# group commands
zstyle ':completion:*:descriptions' format '%F{blue}%d%f'

#───────────────────────────────────────────────────────────────────────────────
# CLI/PLUGIN SETTINGS

export YSU_IGNORED_ALIASES=("bi" "pi") # often copypasted without alias
export YSU_MESSAGE_POSITION="after"

export FZF_DEFAULT_COMMAND='fd'
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
	$FZF_DEFAULT_OPTS --height=50% --preview-window=right,40% -1
	--preview='eza {2} --icons --color=always --no-quotes --width=\$FZF_PREVIEW_COLUMNS'
"

# updates managed via homebrew https://cli.github.com/manual/gh_help_environment
export GH_NO_UPDATE_NOTIFIER=1

#───────────────────────────────────────────────────────────────────────────────
# ZSH PLUGIN SETTINGS

export ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets regexp root)

# DOCS https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/regexp.md
# shellcheck disable=2034 # used in other files
typeset -A ZSH_HIGHLIGHT_REGEXP # actual highlights defined in other files

# DOCS https://github.com/zsh-users/zsh-autosuggestions#configuration
export ZSH_AUTOSUGGEST_HISTORY_IGNORE="?(#c50,)" # ignores long history items
export ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion)
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=30
# do not accept autosuggestion when using vim `A`
export ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=("${ZSH_AUTOSUGGEST_ACCEPT_WIDGETS[@]/vi-add-eol/}")

#───────────────────────────────────────────────────────────────────────────────

# ZSH-AUTOCOMPLETE
# https://github.com/marlonrichert/zsh-autocomplete#configuration

# tab to cycle suggestions
# shellcheck disable=1087,2154
bindkey '\t' menu-select "$terminfo[kcbt]" menu-select
# shellcheck disable=1087
bindkey -M menuselect '\t' menu-complete "$terminfo[kcbt]" reverse-menu-complete

# return to select suggestion & execute
bindkey -M menuselect '\r' .accept-line

# hide info message if there are no completions https://github.com/marlonrichert/zsh-autocomplete/discussions/513
zstyle ':completion:*:warnings' format ""

zstyle ':autocomplete:*' ignored-input '[a-z]|[a-z][a-z]' # ignore single/two letter input
