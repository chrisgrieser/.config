# shellcheck disable=SC1090,SC1091,SC2292

# activate completions, also needed for ZSH auto suggestions & completions
# must be loaded before plugins
autoload compinit -Uz +X && compinit

# Fix for Intel Mac, https://github.com/zsh-users/zsh-completions/issues/433#issuecomment-629539004
if [[ $(uname -p) == "i386" ]]; then
	compaudit | xargs chmod g-w
fi

# INFO zoxide loading in terminal-utils, cause needs to be loaded with configuration
# parameters

# `brew --prefix` ensures the right path is inserted on M1 as well as  non-M1 macs
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# has to be loaded *after* zsh syntax highlighting
source "$(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh"

eval "$(starship init zsh)"
source "$DOTFILE_FOLDER/zsh/plugins/magic_enter.zsh"
source "$DOTFILE_FOLDER/zsh/plugins/obsidian-vault-navigation.sh"

#-------------------------------------------------------------------------------

if [[ "$TERM_PROGRAM" == "Terminus-Sublime" ]] ; then
	TERMINAL="Terminus-Sublime"
elif [[ ${TERM:l} == "alacritty" ]] ; then
	TERMINAL="Alacritty"
elif [[ "$TERM" == "xterm-256color" ]]; then
	TERMINAL="Marta"
fi

# fix for Starship-Terminus issue, https://github.com/starship/starship/issues/3627
if [[ "$TERMINAL" == "Terminus-Sublime" ]] ; then
	export STARSHIP_CONFIG=~/.config/starship/starship_terminus.toml
else
	export STARSHIP_CONFIG=~/.config/starship/starship.toml
fi

