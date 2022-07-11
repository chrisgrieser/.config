# shellcheck disable=SC1090,SC1091,SC2292

# activate completions, also needed for ZSH auto suggestions & completions
autoload compinit -Uz +X && compinit

# Fix for Intel Mac, https://github.com/zsh-users/zsh-completions/issues/433#issuecomment-629539004
if [[ $(uname -p) == "i386" ]]; then
	compaudit | xargs chmod g-w
fi

# needs to be placed after compinit
eval "$(zoxide init zsh)"

# `brew --prefix` ensures the right path is inserted on M1 and non-M1 macs
source "$(brew --prefix)"/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source "$(brew --prefix)"/share/zsh-autosuggestions/zsh-autosuggestions.zsh

eval "$(starship init zsh)"
source "$ZSH_DOTFILE_LOCATION"/plugins/magic_enter.zsh
source "$ZSH_DOTFILE_LOCATION"/plugins/obsidian-vault-navigation.sh

# fix for Starship-Terminus issue, https://github.com/starship/starship/issues/3627
if [[ "$TERM_PROGRAM" == "Terminus-Sublime" ]] ; then
	export STARSHIP_CONFIG=~/.config/starship/starship_terminus.toml
else
	export STARSHIP_CONFIG=~/.config/starship/starship.toml
fi
