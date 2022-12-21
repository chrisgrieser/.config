#!/usr/bin/env zsh
# shellcheck disable=SC2034,SC2164,SC1071

# REQUIREMENTS
# - SSH setup

#-------------------------------------------------------------------------------
# ESSENTIAL

# ask for credentials upfront
sudo -v
setopt INTERACTIVE_COMMENTS

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
xcode-select --install

# get passwords
brew install pinentry-mac pass gnupg

# Install Essential Apps
brew install --no-quarantine alfred hammerspoon neovim alacritty karabiner-elements brave-browser
brew install --no-quarantine --cask neovide

# Key settings
defaults write com.apple.finder QuitMenuItem -bool true # Finder quitable
defaults write org.gpgtools.common DisableKeychain -bool yes # prevent from saving in the keychains

#-------------------------------------------------------------------------------
# DOTFILES / VAULT

cd ~
git clone --recurse-submodules git@github.com:chrisgrieser/.config.git
cd ~/.config
git submodule foreach git checkout main

# load Dock from dotfiles
zsh "$HOME/dotfiles/hammerspoon/dock-switching/dock-switcher.sh" --load home

# REQUIRED: SSH setup
cd ~
git clone git@github.com:chrisgrieser/main-vault-backup.git
git clone git@github.com:chrisgrieser/.password-store.git

#-------------------------------------------------------------------------------
# CREATE SYMLINKS
DOTFILE_FOLDER="$HOME/.config/"

# zsh
[[ -e ~/.zshrc ]] && rm -rf ~/.zshrc
[[ -e ~/.zprofile ]] && rm -rf ~/.zprofile
[[ -e ~/.zshenv ]] && rm -rf ~/.zshenv
ln -sf "$DOTFILE_FOLDER/zsh/.zshrc" ~
ln -sf "$DOTFILE_FOLDER/zsh/.zprofile" ~
ln -sf "$DOTFILE_FOLDER/zsh/.zshenv" ~

# linter configs
ln -sf "$DOTFILE_FOLDER/linter-configs/.stylelintrc.yml" ~
ln -sf "$DOTFILE_FOLDER/linter-configs/.eslintrc.yml" ~
ln -sf "$DOTFILE_FOLDER/linter-configs/.markdownlintrc" ~
ln -sf "$DOTFILE_FOLDER/linter-configs/.pylintrc" ~
ln -sf "$DOTFILE_FOLDER/linter-configs/.shellcheckrc" ~
ln -sf "$DOTFILE_FOLDER/linter-configs/.flake8" ~
ln -sf "$DOTFILE_FOLDER/vale/.vale.ini" ~

# GPG config
mkdir ~/.gnupg
ln -sf "$DOTFILE_FOLDER/gnupg/gpg-agent.conf" ~/.gnupg

# pandoc
[[ -e ~/.pandoc ]] && rm -rf ~/.pandoc
ln -sf "$DOTFILE_FOLDER/pandoc/" ~/.pandoc

# searchlink
[[ -e ~/.searchlink ]] && rm -f ~/.searchlink
ln -sf "$DOTFILE_FOLDER/searchlink/.searchlink" ~

# Hammerspoon
[[ -e ~/.hammerspoon ]] && rm -rf ~/.hammerspoon
ln -sf "$DOTFILE_FOLDER/hammerspoon" ~/.hammerspoon

# Espanso
ESPANSO_DIR=~"/Library/Application Support/espanso"
[[ -e "$ESPANSO_DIR" ]] && rm -rf "$ESPANSO_DIR"
ln -sf "$DOTFILE_FOLDER/espanso/" "$ESPANSO_DIR"

# # Warp
# [[ -e ~/.warp ]] && rm -rf ~/.warp
# ln -sf "$DOTFILE_FOLDER/warp" ~/.warp

# # Fig
# mkdir -p ~/.fig/config
# ln -sf "$DOTFILE_FOLDER/fig/settings.json" ~/.fig

