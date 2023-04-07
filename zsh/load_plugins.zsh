# shellcheck disable=SC1090,SC1091,SC2292

# activate completions, also needed for ZSH auto suggestions & completions
# must be loaded before plugins
autoload compinit -Uz +X && compinit

# Fix for Intel Mac, https://github.com/zsh-users/zsh-completions/issues/433#issuecomment-629539004
[[ $(uname -p) == "i386" ]] && compaudit | xargs chmod g-w

#───────────────────────────────────────────────────────────────────────────────

# "fzf-tab needs to be loaded after compinit, but before plugins which will wrap
# widgets, such as zsh-autosuggestions or fast-syntax-highlighting"
source ~/somewhere/fzf-tab.plugin.zsh


# INFO `brew --prefix` ensures the right path is inserted on M1 as well as  non-M1 macs
source "$(brew --prefix)/share/zsh-you-should-use/you-should-use.plugin.zsh"
source "$(brew --prefix)/share/zsh-autopair/autopair.zsh"
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# has to be loaded *after* zsh syntax highlighting
source "$(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh"

# Magic enter
source "$DOTFILE_FOLDER/zsh/plugins/magic_enter.zsh"

# Starship
eval "$(starship init zsh)"
export STARSHIP_CONFIG=~/.config/starship/starship.toml
[[ "$TERM" == "Warp" ]] && export STARSHIP_CONFIG=~/.config/starship/starship-warp.toml
