#!/usr/bin/env zsh
# shellcheck disable=SC2034,SC2164,SC1071

setopt INTERACTIVE_COMMENTS
# ask for credentials upfront
sudo -v
DOTFILE_FOLDER="$HOME/.config/"

# INFO requires SSH setup
cd ~
git clone git@github.com:chrisgrieser/main-vault.git
git clone git@github.com:chrisgrieser/.password-store.git

#-------------------------------------------------------------------------------

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
xcode-select --install # install core CLIs like git for homebrew

# get passwords
brew install pinentry-mac pass gnupg

# Install Essential Apps
brew install --no-quarantine alfred hammerspoon neovim alacritty karabiner-elements brave-browser
brew install --no-quarantine --cask neovide

# important settings
defaults write com.apple.finder CreateDesktop false # disable desktop icons & make desktop unfocussable
defaults write com.apple.finder QuitMenuItem -bool true # Finder quitable
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
# SYMLINKS

# zsh (ZDOTDIR set in .zshenv for the remaining config)
[[ -e ~/.zshenv ]] && rm -fv ~/.zshenv
ln -sf "$DOTFILE_FOLDER/zsh/.zshenv" ~

# eslint (eslint LSP does not allow custom config paths, also should be used for
# projects anyway)
ln -sf "$DOTFILE_FOLDER/linter-configs/.eslintrc.yml" ~

mkdir -p "$HOME/.codeium"
ln -sf "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles/codium-api-key.json" ~/.codeium/config.json


# GPG config
mkdir ~/.gnupg
ln -sf "$DOTFILE_FOLDER/gnupg/gpg-agent.conf" ~/.gnupg
if [[ $(uname -p) == "i386" ]]; then # FIX for Intel Macs with different homebrew path
	mkdir -p /opt/homebrew/bin/
	ln -sf /usr/local/bin/pinentry-mac /opt/homebrew/bin/pinentry-mac
fi

# searchlink
[[ -e ~/.searchlink ]] && rm -f ~/.searchlink
ln -sf "$DOTFILE_FOLDER/searchlink/.searchlink" ~

# Espanso
ESPANSO_DIR=~"/Library/Application Support/espanso"
[[ -e "$ESPANSO_DIR" ]] && rm -rf "$ESPANSO_DIR"
ln -sf "$DOTFILE_FOLDER/espanso/" "$ESPANSO_DIR"

#───────────────────────────────────────────────────────────────────────────────

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
