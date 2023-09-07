# shellcheck disable=2016
#───────────────────────────────────────────────────────────────────────────────
# https://github.com/Aloxaf/fzf-tab#configure
# https://github.com/Aloxaf/fzf-tab/wiki/Configuration

#───────────────────────────────────────────────────────────────────────────────
# GROUPS

# enable groups
zstyle ':completion:*:descriptions' format '[%d]'

# group descriptions: full/brief
zstyle ':fzf-tab:*' show-group full

# What to show when there is only one group
zstyle ':fzf-tab:*' single-group color prefix


#───────────────────────────────────────────────────────────────────────────────
# MATCHING
# case insensitive path-completion - https://scriptingosx.com/2019/07/moving-to-zsh-part-5-completions/
# INFO even though `fzf` does to smart-case-matching, this does not affect the matching
# for the initial `tab` to open `fzf-tab`, which this snippet does
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 

#───────────────────────────────────────────────────────────────────────────────

# PREVIEW
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza -1 --color=always $realpath'

#───────────────────────────────────────────────────────────────────────────────
# BINDINGS / BEHAVIOR
# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'

# accept with space (similar to regular tab completion)
# accept & run with enter
zstyle ':fzf-tab:*' fzf-bindings 'space:accept'
zstyle ':fzf-tab:*' accept-line enter

# CONTINUOUS-TRIGGER
# It specifies the key to trigger a continuous completion (accept the result and
# start another completion immediately). It's useful when completing a long path.
# here: configured so z and cd go accept & trigger the next completion
zstyle ':fzf-tab:*z*' continuous-trigger 'space'
zstyle ':fzf-tab:*cd*' continuous-trigger 'space'

#───────────────────────────────────────────────────────────────────────────────
# COLORS / APPEARANCE

# make the matched string readable in light mode terminals as well as dark mode ones
zstyle ':fzf-tab:complete:*' fzf-flags '--color=hl:206'

# Disable prefix
zstyle ':fzf-tab:*' prefix ''

# FIX for whatever reason, LS_COLORS is not being set, so setting it here with
# default colors from: https://askubuntu.com/a/1278597
export LS_COLORS="rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:"

# set list-colors to enable filename colorizing
# shellcheck disable=2086,2296
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# color when no group
zstyle ':fzf-tab:*' default-color $'\033[37m'

# group colors
FZF_TAB_GROUP_COLORS=(
    $'\033[94m' $'\033[32m' $'\033[33m' $'\033[35m' $'\033[31m' $'\033[38;5;27m' $'\033[36m' \
    $'\033[38;5;100m' $'\033[38;5;98m' $'\033[91m' $'\033[38;5;80m' $'\033[92m' \
    $'\033[38;5;214m' $'\033[38;5;165m' $'\033[38;5;124m' $'\033[38;5;120m'
)
# shellcheck disable=2086,2128
zstyle ':fzf-tab:*' group-colors $FZF_TAB_GROUP_COLORS
