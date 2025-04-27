# INFO 
# this file assumes that the iCloud folder is already in place
#───────────────────────────────────────────────────────────────────────────────

# ask for credentials upfront
sudo -v
setopt INTERACTIVE_COMMENTS
dotfolder="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder"

#───────────────────────────────────────────────────────────────────────────────

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
xcode-select --install # install core CLIs like `git` for homebrew

# Install Essential Apps first
brew install --no-quarantine alfred hammerspoon neovim wezterm karabiner-elements
brew install --no-quarantine --cask neovide

# important settings
defaults write com.apple.finder CreateDesktop false     # disable desktop icons & make desktop unfocussable
defaults write com.apple.finder QuitMenuItem -bool true # Finder quitable
defaults write org.hammerspoon.Hammerspoon MJConfigFile "$HOME/.config/hammerspoon/init.lua"

#───────────────────────────────────────────────────────────────────────────────

# GPG Keys & Passwords
brew install pinentry-mac pass gnupg
defaults write org.gpgtools.common DisableKeychain -bool yes # prevent from saving in the keychains

gpg --import "$dotfolder/Authentication/passwords and gpg/gpg-pass.key"
ln -sf "$HOME/.config/gpg/gpg-agent.conf" ~/.gnupg/gpg-agent.conf
gpgconf --kill gpg-agent # restart so the new gpg agent is recognized
find ~/.gnupg -type f -exec chmod 600 {} \;
find ~/.gnupg -type d -exec chmod 700 {} \;

# FIX for gpg config on Intel Macs with different homebrew path
if [[ $(uname -p) == "i386" ]]; then
	mkdir -p /opt/homebrew/bin/
	ln -sf /usr/local/bin/pinentry-mac /opt/homebrew/bin/pinentry-mac
fi

#───────────────────────────────────────────────────────────────────────────────
# REPOS: Dotfiles, Passwords

# SSH
ln -sf "$dotfolder/Authentication/ssh/" ~/.ssh
sudo chmod -R 700 ~/.ssh/id_ed25519

cd ~ || return 1
[[ -e ~/.config ]] && rm -rfv ~/.config
git clone git@github.com:chrisgrieser/.config
git clone git@github.com:chrisgrieser/.password-store

#───────────────────────────────────────────────────────────────────────────────

# zsh (ZDOTDIR set in .zshenv for the remaining config)
ln -sf "$HOME/.config/zsh/.zshenv" ~

# shellcheck disable=1091
source "$HOME/.config/zsh/.zshrc"
