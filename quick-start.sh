#!/usr/bin/env zsh
# shellcheck disable=SC2034,SC2164,SC1071

#-------------------------------------------------------------------------------
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
defaults write com.apple.finder QuitMenuItem -bool true      # Finder quitable
defaults write org.gpgtools.common DisableKeychain -bool yes # prevent from saving in the keychains

#-------------------------------------------------------------------------------
# DOTFILES / VAULT

cd ~
[[ -e ~/.config ]] && rm -rfv ~/.config
git clone --recurse-submodules git@github.com:chrisgrieser/.config.git
cd ~/.config
git submodule foreach git checkout main

# load Dock from dotfiles
zsh "$HOME/dotfiles/hammerspoon/dock-switching/dock-switcher.sh" --load home

# REQUIRED SSH setup
cd ~
git clone git@github.com:chrisgrieser/main-vault.git
git clone git@github.com:chrisgrieser/.password-store.git

#-------------------------------------------------------------------------------
# CREATE SYMLINKS
DOTFILE_FOLDER="$HOME/.config/"

# zsh
[[ -e ~/.zshrc ]] && rm -fv ~/.zshrc
[[ -e ~/.zprofile ]] && rm -fv ~/.zprofile
[[ -e ~/.zshenv ]] && rm -fv ~/.zshenv
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

#───────────────────────────────────────────────────────────────────────────────

# INFO: already set up, no need to run again.
# Only left here for reference, or when dotfile folder location is changed

# # Brave PWAs
# [[ -e ~"/Applications/$BROWSER Apps.localized" ]] && rm -rf ~"/Applications/$BROWSER Apps.localized"
# ln -sf ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/$BROWSER Apps.localized/" ~"/Applications/$BROWSER Apps.localized"

# # to keep private stuff out of the dotfile repo
# ln -sf ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles/hammerspoon-private.lua" "$DOTFILE_FOLDER/hammerspoon/lua/private.lua"
# ln -sf ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles/espanso-private.yml" "$DOTFILE_FOLDER/espanso/match/private.yml"
# ln -sf ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles/spotify-tui-client.yml" "$DOTFILE_FOLDER/.config/spotify-tui/client.yml"
# ln -sf ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles/spotify_token_cache.json" "$DOTFILE_FOLDER/.config/spotify-tui/.spotify_token_cache.json"

# # Obsidian vimrc
# ln -sf "$DOTFILE_FOLDER/obsidian/obsidian.vimrc" "$VAULT_PATH/Meta"
# ln -sf "$DOTFILE_FOLDER/obsidian/obsidian-vim-helpers.js" "$VAULT_PATH/Meta"
# ln -sf "$DOTFILE_FOLDER/obsidian/obsidian.vimrc" "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Development/Meta"
# ln -sf "$DOTFILE_FOLDER/obsidian/obsidian-vim-helpers.js" "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Development/Meta"
