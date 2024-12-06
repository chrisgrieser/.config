# DOCS
# official docs             https://zsh.sourceforge.io/Guide/zshguide06.html
# zstyle                    https://zsh.sourceforge.io/Doc/Release/Completion-System.html#Standard-Styles
# good guide                https://thevaluable.dev/zsh-completion-guide-examples/
# zsh-autocomplete config   https://github.com/marlonrichert/zsh-autocomplete#configuration
# zsh-autocomplete presets  https://github.com/marlonrichert/zsh-autocomplete/blob/main/Functions/Init/.autocomplete__config
#───────────────────────────────────────────────────────────────────────────────

# FORMAT / COLOR
# color completion groups with purple-gray background (ccc.nvim highlight is wrong)
zstyle ':completion:*:descriptions' format $'\e[7;38;5;103m %d \e[0;38;5;103m \e[0m'

# color items in specific group
zstyle ':completion:*:aliases' list-colors '=*=35'

# 1. option descriptions in gray (`38;5;245` is visible in dark and light mode)
# 2. apply LS_COLORS to files/directories
# 3. selected item (styled via `ma=`)
zstyle ':completion:*:default' list-colors \
	'=(#b)*(-- *)=39=38;5;245' \
	"$LS_COLORS" \
	"ma=7;38;5;68"

# hide info message if there are no completions https://github.com/marlonrichert/zsh-autocomplete/discussions/513
zstyle ':completion:*:warnings' format ""

# print help messages in blue (affects for instance `just` recipe-descriptions)
zstyle ':completion:*:messages' format $'\e[3;34m%d\e[0m'

#───────────────────────────────────────────────────────────────────────────────
# BINDINGS
bindkey '\t' menu-select   # <Tab> start completion, BUG not working https://github.com/marlonrichert/zsh-autocomplete/issues/749
bindkey '^[[Z' menu-select # <S-Tab> start completion

bindkey -M menuselect '\t' menu-complete           # <Tab> next item
bindkey -M menuselect '^[[Z' reverse-menu-complete # <S-Tab> prev suggestion
bindkey -M menuselect '\r' .accept-line            # <CR> select & execute

#───────────────────────────────────────────────────────────────────────────────
# SORT

zstyle ':completion:*' file-sort modification follow # "follow" makes it follow symlinks

# INFO inserting "path-directories" to add "directories in cdpath" to the top
zstyle ':completion:*' group-order \
	path-directories local-directories directories \
	all-expansions expansions options \
	aliases suffix-aliases functions reserved-words builtins commands executables \
	remotes hosts recent-branches commits

#────────────────────────────────────────────────────────────────────────────

# IGNORE
# remove the _ignored completer set by zsh-autocomplete, so things ignored by
# `ignored-patterns` take effect (https://stackoverflow.com/a/67510126)
zstyle ':completion:*' completer \
	_expand _complete _correct _approximate _complete:-fuzzy _prefix

zstyle ':completion:*' ignored-patterns \
	".git" ".DS_Store" ".localized" "node_modules" "__pycache__"

zstyle ':autocomplete:*' ignored-input '..d' # zsh-autocomplete

#───────────────────────────────────────────────────────────────────────────────
# do not save in dotfile repo
export ZSH_COMPDUMP="$HOME/.local/share/zsh/zcompdump"
