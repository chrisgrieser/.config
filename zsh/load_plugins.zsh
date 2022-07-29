# shellcheck disable=SC1090,SC1091,SC2292

# activate completions, also needed for ZSH auto suggestions & completions
autoload compinit -Uz +X && compinit

# Fix for Intel Mac, https://github.com/zsh-users/zsh-completions/issues/433#issuecomment-629539004
if [[ $(uname -p) == "i386" ]]; then
	compaudit | xargs chmod g-w
fi

# zoxide loading in terminal-utils, cause needs to be loaded with configuration
# parameters

# fzf tab needs to be loaded after compinit, but before zsh-syntax-highlighting and zsh-autosuggestions
source "$DOTFILE_FOLDER/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh"

# `brew --prefix` ensures the right path is inserted on M1 as well as  non-M1 macs
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

eval "$(starship init zsh)"
source "$DOTFILE_FOLDER/zsh/plugins/magic_enter.zsh"
source "$DOTFILE_FOLDER/zsh/plugins/obsidian-vault-navigation.sh"

# fix for Starship-Terminus issue, https://github.com/starship/starship/issues/3627
if [[ "$TERM_PROGRAM" == "Terminus-Sublime" ]] ; then
	export STARSHIP_CONFIG=~/.config/starship/starship_terminus.toml
else
	export STARSHIP_CONFIG=~/.config/starship/starship.toml
fi

