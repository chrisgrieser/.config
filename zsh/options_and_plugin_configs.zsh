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

# group commands & color groups
# see https://github.com/marlonrichert/zsh-autocomplete/issues/654
zstyle ':completion:*:descriptions' format $'\033[1;34m%d\033[0m'

#───────────────────────────────────────────────────────────────────────────────
# CLI/PLUGIN SETTINGS

# FIX for whatever reason, LS_COLORS is not being set, so setting it here with
# default colors from: https://askubuntu.com/a/1278597
export LS_COLORS="rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:"

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
export EZA_ICONS_AUTO=1

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
export ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd history completion)
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

zstyle ':autocomplete:*' min-input 3 # minimum number of characters before suggestions are shown
