#!/usr/bin/env zsh
# shellcheck disable=SC2034,SC2164,SC1071

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
git clone git@github.com:chrisgrieser/main-vault-backup.git
git clone 
git clone --recurse-submodules git@github.com:chrisgrieser/.config.git
cd ~/.config
git submodule foreach git checkout main

# load Dock from dotfiles
zsh "$HOME/dotfiles/hammerspoon/dock-switching/dock-switcher.sh" --load home

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

# GPG
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

#───────────────────────────────────────────────────────────────────────────────
# Warp
# [[ -e ~/.warp ]] && rm -rf ~/.warp
# ln -sf "$DOTFILE_FOLDER/warp" ~/.warp

# Marta
# INFO: Marta as default folder opener set in Duti Script
# ln -sf /Applications/Marta.app/Contents/Resources/launcher /opt/homebrew/bin/marta
# MARTA_DIR=~"/Library/Application Support/org.yanex.marta"
# [[ -e "$MARTA_DIR" ]] && rm -rf "$MARTA_DIR"
# ln -sf "$DOTFILE_FOLDER/Marta" "$MARTA_DIR"

#───────────────────────────────────────────────────────────────────────────────

# INFO: already set up, no need to run again.
# Only left here for reference, or when dotfile folder location is changed

# Brave PWAs
# BROWSER="Brave Browser"
# [[ -e ~"/Applications/$BROWSER Apps.localized" ]] && rm -rf ~"/Applications/$BROWSER Apps.localized"
# ln -sf ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/$BROWSER Apps.localized/" ~"/Applications/$BROWSER Apps.localized"

# to keep private stuff out of the dotfile repo
# ln -sf ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles/hammerspoon-private.lua" "$DOTFILE_FOLDER/hammerspoon/lua/private.lua"
# ln -sf ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles/espanso-private.yml" "$DOTFILE_FOLDER/espanso/match/private.yml"
# ln -sf ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles/spotify-tui-client.yml" "$DOTFILE_FOLDER/.config/spotify-tui/client.yml"
# ln -sf ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles/spotify_token_cache.json" "$DOTFILE_FOLDER/.config/spotify-tui/.spotify_token_cache.json"

# Obsidian vimrc
# ln -sf "$DOTFILE_FOLDER/obsidian-vim/obsidian.vimrc" "$HOME/main-vault/Meta"
# ln -sf "$DOTFILE_FOLDER/obsidian-vim/obsidian-vim-helpers.js" "$HOME/main-vault/Meta"
# ln -sf "$DOTFILE_FOLDER/obsidian-vim/obsidian.vimrc" "$HOME/Development/Meta"
# ln -sf "$DOTFILE_FOLDER/obsidian-vim/obsidian-vim-helpers.js" "$HOME/Development/Meta"
