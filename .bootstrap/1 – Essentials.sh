#!/usr/bin/env zsh
# shellcheck disable=SC2034,SC2164,SC1071

# ask for credentials upfront
sudo -v
setopt INTERACTIVE_COMMENTS

DATA_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder"

#───────────────────────────────────────────────────────────────────────────────

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
xcode-select --install # install core CLIs like git for homebrew

# Install Essential Apps
brew install --no-quarantine alfred hammerspoon neovim wezterm karabiner-elements
brew install --no-quarantine --cask neovide

# important settings
defaults write com.apple.finder CreateDesktop false     # disable desktop icons & make desktop unfocussable
defaults write com.apple.finder QuitMenuItem -bool true # Finder quitable
defaults write org.hammerspoon.Hammerspoon MJConfigFile "$HOME/.config/hammerspoon/init.lua"

zsh "$HOME/.config/hammerspoon/dock-switching/dock-switcher.sh" --load home

#───────────────────────────────────────────────────────────────────────────────

# GPG Keys & Passwords
brew install pinentry-mac pass gnupg
defaults write org.gpgtools.common DisableKeychain -bool yes # prevent from saving in the keychains

gpg --import "$DATA_DIR/Authentication/passwords and gpg/gpg-pass.key"
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
# REPOS: Dotfiles, Vault, Passwords

# SSH
ln -sf "$DATA_DIR/Authentication/ssh/" ~/.ssh
sudo chmod -R 700 ~/.ssh/id_ed25519

cd ~
[[ -e ~/.config ]] && rm -rfv ~/.config
git clone git@github.com:chrisgrieser/.config.git
git clone git@github.com:chrisgrieser/main-vault.git
git clone git@github.com:chrisgrieser/.password-store.git

#───────────────────────────────────────────────────────────────────────────────
# LOAD CONFIGS (MACKUP)

ln -sf "$HOME/.config/mackup/mackup.cfg" ~/.mackup.cfg
ln -sf "$HOME/.config/mackup/custom-app-configs" ~/.mackup
brew install mackup
mackup restore --force && mackup uninstall --force # sets symlinks, and then writes full files

#───────────────────────────────────────────────────────────────────────────────
# CREATE SYMLINKS

# zsh (ZDOTDIR set in .zshenv for the remaining config)
ln -sf "$HOME/.config/zsh/.zshenv" ~

# Fig
# ln -sf "$HOME/.config/fig/settings.json" ~/.fig/settings.json
# fig install --input-method

# Espanso
ESPANSO_DIR=~"/Library/Application Support/espanso"
[[ -e "$ESPANSO_DIR" ]] && rm -rf "$ESPANSO_DIR"
ln -sf "$HOME/.config/espanso/" "$ESPANSO_DIR"

# Browser PWAs
[[ -e ~"/Applications/$BROWSER_APP Apps.localized" ]] && rm -rf ~"/Applications/$BROWSER_APP Apps.localized"
ln -sf ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/$BROWSER_APP Apps.localized/" ~"/Applications/$BROWSER_APP Apps.localized"

#───────────────────────────────────────────────────────────────────────────────
