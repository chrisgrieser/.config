# shellcheck disable=2016
#───────────────────────────────────────────────────────────────────────────────
# https://github.com/Aloxaf/fzf-tab#configure
# https://github.com/Aloxaf/fzf-tab/wiki/Configuration

#───────────────────────────────────────────────────────────────────────────────
# GROUPS

# enable groups
zstyle ':completion:*:descriptions' format '[%d]'

# group definitions
zstyle ':completion:*' group-name ''
zstyle ':completion:*:*:-command-:*:*' group-order alias builtins functions commands

# group descriptions: full/brief
zstyle ':fzf-tab:*' show-group full

# What to show when there is only one group
zstyle ':fzf-tab:*' single-group color prefix


#───────────────────────────────────────────────────────────────────────────────
# MATCHING
# case insensitive path-completion - https://scriptingosx.com/2019/07/moving-to-zsh-part-5-completions/
# not needed with fzf-tab
# zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 

#───────────────────────────────────────────────────────────────────────────────

# PREVIEW
# preview directory's content with exa when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
zstyle ':fzf-tab:complete:z:*' fzf-preview 'exa -1 --color=always $realpath'

#───────────────────────────────────────────────────────────────────────────────
# BINDINGS / BEHAVIOR
# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'

# case insensitive path-completion - https://scriptingosx.com/2019/07/moving-to-zsh-part-5-completions/
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 

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

# Disable prefix
zstyle ':fzf-tab:*' prefix ''

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
