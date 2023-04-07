# https://github.com/Aloxaf/fzf-tab#configure
# https://github.com/Aloxaf/fzf-tab/wiki/Configuration
#───────────────────────────────────────────────────────────────────────────────

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false

# disable sort when completing options of any command
zstyle ':completion:complete:*:options' sort false

# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'

# preview directory's content with exa when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'

# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'

# group description
zstyle ':completion:*:descriptions' format

#───────────────────────────────────────────────────────────────────────────────
# COLORS

# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# color when no group
zstyle ':fzf-tab:*' default-color $'\033[37m'

# grup colors
FZF_TAB_GROUP_COLORS=(
    $'\033[94m' $'\033[32m' $'\033[33m' $'\033[35m' $'\033[31m' $'\033[38;5;27m' $'\033[36m' \
    $'\033[38;5;100m' $'\033[38;5;98m' $'\033[91m' $'\033[38;5;80m' $'\033[92m' \
    $'\033[38;5;214m' $'\033[38;5;165m' $'\033[38;5;124m' $'\033[38;5;120m'
)
zstyle ':fzf-tab:*' group-colors $FZF_TAB_GROUP_COLORS
