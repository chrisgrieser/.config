#!/usr/bin/env zsh
# shellcheck disable=SC2034,SC2164

#-------------------------------------------------------------------------------
# ESSENTIAL

# ask for credentials upfront
sudo -v

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
xcode-select --install

# Install Essential Apps
brew install --no-quarantine macpass alfred hammerspoon neovim alacritty karabiner-elements brave-browser
brew install --no-quarantine neovide --cask

# Hammerspoon
defaults write "org.hammerspoon.Hammerspoon" "MJShowMenuIconKey" 0
defaults write "org.hammerspoon.Hammerspoon" "HSUploadCrashData" 0
defaults write "org.hammerspoon.Hammerspoon" "MJKeepConsoleOnTopKey" 1
defaults write "org.hammerspoon.Hammerspoon" "SUEnableAutomaticChecks" 1

#-------------------------------------------------------------------------------
# DOTFILES / VAULT

cd ~
git clone git@github.com:chrisgrieser/main-vault-backup.git
git clone --recurse-submodules git@github.com:chrisgrieser/dotfiles.git
cd ~/dotfiles
git submodule foreach git checkout main
mv "main-vault-backup" "Main Vault"

# load Dock from dotfiles
zsh "$HOME/dotfiles/hammerspoon/dock-switching/dock-switcher.sh" --load home

#-------------------------------------------------------------------------------
# CREATE SYMLINKS

DOTFILE_FOLDER="$(dirname "$0")"

# zsh
[[ -e ~/.zshrc ]] && rm -rf ~/.zshrc
ln -sf "$DOTFILE_FOLDER/zsh/.zshrc" ~
[[ -e ~/.zprofile ]] && rm -rf ~/.zprofile
ln -sf "$DOTFILE_FOLDER/zsh/.zprofile" ~
ln -sf "$DOTFILE_FOLDER/zsh/.zshenv" ~
ln -sf "$DOTFILE_FOLDER/.config/nano/nanorc" ~/.nanorc

# .config
[[ -e ~/.config ]] && rm -rf ~/.config
ln -sf "$DOTFILE_FOLDER/.config/" ~/.config

# other dotfiles
ln -sf "$DOTFILE_FOLDER/.searchlink" ~
ln -sf "$DOTFILE_FOLDER/.vimrc" ~
ln -sf "$DOTFILE_FOLDER/pandoc/" ~/.pandoc

# linter rcfiles
ln -sf "$DOTFILE_FOLDER/linter rcfiles/.stylelintrc.json" ~
ln -sf "$DOTFILE_FOLDER/linter rcfiles/.eslintrc.json" ~
ln -sf "$DOTFILE_FOLDER/linter rcfiles/.markdownlintrc" ~
ln -sf "$DOTFILE_FOLDER/linter rcfiles/.pylintrc" ~
ln -sf "$DOTFILE_FOLDER/linter rcfiles/.shellcheckrc" ~
ln -sf "$DOTFILE_FOLDER/linter rcfiles/.flake8" ~

# Hammerspoon
[[ -e ~/.hammerspoon ]] && rm -rf ~/.hammerspoon
ln -sf "$DOTFILE_FOLDER/hammerspoon" ~/.hammerspoon

# Marta
# Marta as default folder opener set in Duti Script
ln -sf /Applications/Marta.app/Contents/Resources/launcher /opt/homebrew/bin/marta
MARTA_DIR=~"/Library/Application Support/org.yanex.marta"
if [[ -e "$MARTA_DIR" ]] ; then
	rm -rf "$MARTA_DIR"
else
	mkdir -p "$MARTA_DIR"
fi
ln -sf ~"/dotfiles/Marta" "$MARTA_DIR"

# Espanso
ESPANSO_DIR=~"/Library/Application Support/espanso"
if [[ -e "$ESPANSO_DIR" ]] ; then
	rm -rf "$ESPANSO_DIR"
else
	mkdir -p "$ESPANSO_DIR"
fi
ln -sf "$DOTFILE_FOLDER/espanso/" "$ESPANSO_DIR"

# Brave PWAs
BROWSER="Brave Browser"
if [[ -e ~"/Applications/$BROWSER Apps.localized" ]] ; then
	rm -rf ~"/Applications/$BROWSER Apps.localized"
else
	mkdir -p ~"/Applications/$BROWSER Apps.localized"
fi
ln -sf ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/$BROWSER Apps.localized/" ~"/Applications/$BROWSER Apps.localized"

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# INFO: already set up, no need to run again.
# Only left here for reference, or when dotfile folder location changes

# # to keep private stuff out of the dotfile repo
# ln -sf ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles/hammerspoon-private.lua" "$DOTFILE_FOLDER/hammerspoon/private.lua"
# ln -sf ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles/espanso-private.yml" "$DOTFILE_FOLDER/espanso/match/private.yml"
# ln -sf ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles/spotify-tui-client.yml" "$DOTFILE_FOLDER/.config/spotify-tui/client.yml"
# ln -sf ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles/spotify_token_cache.json" "$DOTFILE_FOLDER/.config/spotify-tui/.spotify_token_cache.json"

# Obsidian vimrc
# ln -sf "$DOTFILE_FOLDER/Obsidian vim/obsidian.vimrc" "$HOME/Main Vault/Meta"
# ln -sf "$DOTFILE_FOLDER/Obsidian vim/obsidian-vim-helpers.js" "$HOME/Main Vault/Meta"
# ln -sf "$DOTFILE_FOLDER/Obsidian vim/obsidian.vimrc" "$HOME/Development/Meta"
# ln -sf "$DOTFILE_FOLDER/Obsidian vim/obsidian-vim-helpers.js" "$HOME/Development/Meta"
# ln -sf "$DOTFILE_FOLDER/pandoc/README.md" "$HOME/Main Vault/Knowledge Base/Pandoc.md"
