#!/usr/bin/env zsh
# shellcheck disable=SC2034,SC2164,SC1071

DOTFILE_FOLDER="$HOME/.config/"

REQUIRED SSH setup
cd ~
git clone git@github.com:chrisgrieser/main-vault.git
git clone git@github.com:chrisgrieser/.password-store.git

#-------------------------------------------------------------------------------
# ask for credentials upfront
sudo -v
setopt INTERACTIVE_COMMENTS

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
xcode-select --install # install core CLIs like git for homebrew

# get passwords
brew install pinentry-mac pass gnupg

# Install Essential Apps
brew install --no-quarantine alfred hammerspoon neovim alacritty karabiner-elements brave-browser
brew install --no-quarantine --cask neovide

# important settings
defaults write com.apple.finder CreateDesktop false          # disable desktop icons & make desktop unfocussable
defaults write com.apple.finder QuitMenuItem -bool true      # Finder quitable
defaults write org.gpgtools.common DisableKeychain -bool yes # prevent from saving in the keychains
defaults write org.hammerspoon.Hammerspoon MJConfigFile "$DOTFILE_FOLDER/hammerspoon/init.lua"

#-------------------------------------------------------------------------------
# DOTFILES / VAULT

cd ~
[[ -e ~/.config ]] && rm -rfv ~/.config
git clone --recurse-submodules git@github.com:chrisgrieser/.config.git
cd ~/.config
git submodule foreach git checkout main

# load Dock from dotfiles
zsh "$DOTFILE_FOLDER/hammerspoon/dock-switching/dock-switcher.sh" --load home

#-------------------------------------------------------------------------------
# CREATE SYMLINKS

# zsh (ZDOTDIR set in .zshenv for the remaining config)
[[ -e ~/.zshenv ]] && rm -fv ~/.zshenv
ln -sf "$DOTFILE_FOLDER/zsh/.zshenv" ~

# eslint (eslint LSP does not allow custom config paths, also should be used for
# projects )
ln -sf "$DOTFILE_FOLDER/linter-configs/.eslintrc.yml" ~

# GPG config
mkdir ~/.gnupg
ln -sf "$DOTFILE_FOLDER/gnupg/gpg-agent.conf" ~/.gnupg
if [[ $(uname -p) == "i386" ]]; then # FIX for Intel Macs with different homebrew path
	mkdir -p /opt/homebrew/bin/
	ln -sf /usr/local/bin/pinentry-mac /opt/homebrew/bin/pinentry-mac
fi

# pandoc
[[ -e ~/.pandoc ]] && rm -rf ~/.pandoc
ln -sf "$DOTFILE_FOLDER/pandoc/" ~/.pandoc

# searchlink
[[ -e ~/.searchlink ]] && rm -f ~/.searchlink
ln -sf "$DOTFILE_FOLDER/searchlink/.searchlink" ~

# Espanso
ESPANSO_DIR=~"/Library/Application Support/espanso"
[[ -e "$ESPANSO_DIR" ]] && rm -rf "$ESPANSO_DIR"
ln -sf "$DOTFILE_FOLDER/espanso/" "$ESPANSO_DIR"

# Browser PWAs
BROWSER="Chrome" # Chrome = Vivaldi, since Vivaldi does not rename the dir
# BROWSER="Brave Browser"
[[ -e ~"/Applications/$BROWSER Apps.localized" ]] && rm -rf ~"/Applications/$BROWSER Apps.localized"
ln -sf ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/$BROWSER Apps.localized/" ~"/Applications/$BROWSER Apps.localized"

#───────────────────────────────────────────────────────────────────────────────

# # Warp
# [[ -e ~/.warp ]] && rm -rf ~/.warp
# ln -sf "$DOTFILE_FOLDER/warp" ~/.warp

# # Fig
# mkdir -p ~/.fig/config
# ln -sf "$DOTFILE_FOLDER/fig/settings.json" ~/.fig
